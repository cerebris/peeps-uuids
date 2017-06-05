# Peeps-UUIDs: A demo of JSONAPI-Resources using UUIDs and Postgresql

Peeps-UUIDs is a very basic contact management system implemented as an API that follows the JSON API spec. Peeps-UUIDs is based on https://github.com/cerebris/peeps.

Other apps will soon be written to demonstrate writing a consumer for this API.

## Running this app

This app requires that postgresql be installed locally. General instructions are available 
[here](https://wiki.postgresql.org/wiki/Detailed_installation_guides) for many operating systems.

After cloning this repo, run the following:

```bash
bundle
```

Ensure that your `config/database.yml` is configured properly, and then run:

```bash
rake db:create db:migrate
```

Start your server:

```bash
rails server
```

## Steps taken to create this app

The instructions below were followed to create this app from scratch.

### Create a new Rails application

```bash
rails new peeps-uuids -d postgresql --skip-javascript
```

### Setup your database.yml

The default database.yml may not work for your configuration, so you will need to set this up based on your installation.

### Create the databases

```bash
rake db:create
```

### Add the JSONAPI-Resources gem
Add the gem to your Gemfile

```bash
gem 'jsonapi-resources'
```

Then bundle

```bash
bundle
```

### Application Controller 
Make the following changes to application_controller.rb

```ruby
class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
end
```

OR

```ruby
class ApplicationController < JSONAPI::ResourceController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
end
```

You can also do this on a per controller basis in your app, if only some controllers will serve the API.

### Configure Development Environment
Edit config/environments/development.rb

Eager loading of classes is recommended. The code will work without it, but I think it's the right way to go.
See http://blog.plataformatec.com.br/2012/08/eager-loading-for-greater-good/

```ruby
  # Eager load code on boot so JSONAPI-Resources resources are loaded and processed globally
  config.eager_load = true
```

```ruby
config.consider_all_requests_local       = false
```

This will prevent the server from returning the HTML formatted error messages when an exception happens. Not strictly
necessary, but it makes for nicer output when debugging using curl or a client library.

### Turn on UUID support for PostgreSQL

Create a migration to enable UUID support.

```bash
rails g migration EnableUuids
```

Edit the migration

```ruby
class EnableUuids < ActiveRecord::Migration
  def change
    enable_extension 'pgcrypto'
  end
end
```

### Migrate the DB

```bash
rake db:migrate
```

### Tell JR that we're using UUID keys

Create an initializer, such as `config/initializers/jsonapi.rb`, that contains the following:

```ruby
JSONAPI.configure do |config|
  # Allowed values are :integer(default), :uuid, :string, or a proc
  config.resource_key_type = :uuid
end
```

This setting could alternatively be made on a per-resource basis.

## Now let's fill out the app

### Create Models for our data

Use the standard rails generator to create a model for Contacts and one for related PhoneNumbers

```bash
rails g model Contact first_name:string last_name:string email:string twitter:string
```

Edit the migration to set the id to use uuids

```ruby
class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts, id: :uuid  do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :twitter

      t.timestamps
    end
  end
end
```

Edit the model

```ruby
class Contact < ApplicationRecord
  has_many :phone_numbers

  ### Validations
  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.creatable_fields(context)
    super + [:id]
  end
end
```

Create the PhoneNumber model

```bash
rails g model PhoneNumber contact_id:integer name:string phone_number:string
```

Edit the migration for uuid

```ruby
class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers, id: :uuid do |t|
      t.uuid :contact_id
      t.string :name
      t.string :phone_number

      t.timestamps
    end
  end
end
```

Edit the model

```ruby
class PhoneNumber < ApplicationRecord
  belongs_to :contact

  def self.creatable_fields(context)
    super + [:id]
  end
end
```

### Migrate the DB

```bash
rake db:migrate
```

### Create Controllers
Use the rails generator to create empty controllers. These will be inherit methods from the ResourceController so
they will know how to respond to the standard REST methods.

```bash
rails g controller Contacts --skip-assets
rails g controller PhoneNumbers --skip-assets
```

### Create our resources directory

We need a directory to hold our resources. Let's put in under our app directory

```bash
mkdir app/resources
```

### Create the resources

Create a new file for each resource. This must be named in a standard way so it can be found. This should be the single
underscored name of the model with \_resource.rb appended. For Contacts this will be contact_resource.rb.

Make the two resource files

contact_resource.rb

```ruby
class ContactResource < JSONAPI::Resource
  attributes :first_name, :last_name, :email, :twitter
  has_many :phone_numbers
end
```

and phone_number_resource.rb

```ruby
class PhoneNumberResource < JSONAPI::Resource
  attributes :name, :phone_number
  has_one :contact

  filter :contact
end

```

### Setup routes

Require jsonapi/routing_ext

```ruby
require 'jsonapi/routing_ext'
```

Add the routes for the new resources

```ruby
UUID_regex = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(,[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})*/

jsonapi_resources :contacts, constraints: {:id => UUID_regex}
jsonapi_resources :phone_numbers, constraints: {:id => UUID_regex}
```

## Test it out

Launch the app

```bash
rails server
```

Create a new contact
```bash
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"contacts", "attributes":{"first-name":"John", "last-name":"Doe", "email":"john.doe@example.com"}}}' http://localhost:3000/contacts
```

You should get something like this back
```
HTTP/1.1 201 Created
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
Location: http://localhost:3000/contacts/77eec4e9-4244-492d-8340-18892e2c54b2
ETag: W/"1b5c63402a02363d3985132d8298bcee"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 34785427-6427-43ec-8fc7-34dc64a17e5b
X-Runtime: 0.023691
Transfer-Encoding: chunked

{"data":{"id":"77eec4e9-4244-492d-8340-18892e2c54b2","type":"contacts","links":{"self":"http://localhost:3000/contacts/77eec4e9-4244-492d-8340-18892e2c54b2"},"attributes":{"first-name":"John","last-name":"Doe","email":"john.doe@example.com","twitter":null},"relationships":{"phone-numbers":{"links":{"self":"http://localhost:3000/contacts/77eec4e9-4244-492d-8340-18892e2c54b2/relationships/phone-numbers","related":"http://localhost:3000/contacts/77eec4e9-4244-492d-8340-18892e2c54b2/phone-numbers"}}}}}
```

You can now create a phone number for this contact

```
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{ "data": { "type": "phone-numbers", "relationships": { "contact": { "data": { "type": "contacts", "id": "77eec4e9-4244-492d-8340-18892e2c54b2" } } }, "attributes": { "name": "home", "phone-number": "(603) 555-1212" } } }' http://localhost:3000/phone-numbers
```

And you should get back something like this:

```
HTTP/1.1 201 Created
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
Location: http://localhost:3000/phone-numbers/13a8befe-8958-49ed-9b94-a71768986465
ETag: W/"878009bdc1ac40d69706504a48ed49eb"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 3e345e2b-3ecf-44a4-92e6-c943e26413da
X-Runtime: 0.024379
Transfer-Encoding: chunked

{"data":{"id":"13a8befe-8958-49ed-9b94-a71768986465","type":"phone-numbers","links":{"self":"http://localhost:3000/phone-numbers/13a8befe-8958-49ed-9b94-a71768986465"},"attributes":{"name":"home","phone-number":"(603) 555-1212"},"relationships":{"contact":{"links":{"self":"http://localhost:3000/phone-numbers/13a8befe-8958-49ed-9b94-a71768986465/relationships/contact","related":"http://localhost:3000/phone-numbers/13a8befe-8958-49ed-9b94-a71768986465/contact"}}}}}
```

You can now query all one of your contacts

```bash
curl -i -H "Accept: application/vnd.api+json" "http://localhost:3000/contacts"
```

And you get this back:

```
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
ETag: W/"aec78dabf2895bf6c4a9a7c4374e881e"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 0541fb25-6493-4d6a-a78a-2d3bf4b78330
X-Runtime: 0.005499
Transfer-Encoding: chunked

{"data":[{"id":"77eec4e9-4244-492d-8340-18892e2c54b2","type":"contacts","links":{"self":"http://localhost:3000/contacts/77eec4e9-4244-492d-8340-18892e2c54b2"},"attributes":{"first-name":"John","last-name":"Doe","email":"john.doe@example.com","twitter":null},"relationships":{"phone-numbers":{"links":{"self":"http://localhost:3000/contacts/77eec4e9-4244-492d-8340-18892e2c54b2/relationships/phone-numbers","related":"http://localhost:3000/contacts/77eec4e9-4244-492d-8340-18892e2c54b2/phone-numbers"}}}}]}
```

Note that the phone_number id is included in the links, but not the details of the phone number. You can get these by
setting an include:

```bash
curl -i -H "Accept: application/vnd.api+json" "http://localhost:3000/contacts?include=phone-numbers"
```

and some fields:

```bash
curl -i -H "Accept: application/vnd.api+json" "http://localhost:3000/contacts?include=phone-numbers&fields%5Bcontacts%5D=fist-name,last-name&fields%5Bphone-numbers%5D=name"
```

Test a validation Error

```bash
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{ "data": { "type": "contacts", "attributes": { "first-name": "John Doe", "email": "john.doe@boring.test" } } }' http://localhost:3000/contacts
```
