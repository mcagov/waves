# Waves Internal App

## About

This app currently consists of a vessel submission API and a content
management system. The API is intended to support on the
Gov.UK hosted website as a means for the owner of a (singley owned) small ship to
register their vessel under **Part III of the UK Ships Register**. The content
management system is intended to be a means of managing the register and
workload of officers of the [Maritime and Coastguard Agency][mca].

[mca]: https://www.gov.uk/government/organisations/maritime-and-coastguard-agency

##### Architecture

This is a standard Rails 5.2 web app with a PostgreSQL database.

##### Look & Feel

[Bootstrap][bootstrap] has been used to theme the internal dashboard.

[bootstrap]: https://getbootstrap.com/

#### Setup

To set up a new development environment, follow the steps below:

    bundle install
    cp .env.example .env
    cp config/database.yml.example config/database.yml

Then complete the `.env` file with your environment settings, and complete the
`config/database.yml` file with your database settings.

Setup your databases with:

    bundle exec rake db:setup
    bundle exec rake db:test:prepare

##### Installation issues

If capybara-webkit fails when you run `bundle install`, refer to the [capybara-webkit help page](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit)

#### Running the webserver locally

To run the app locally:

    bundle exec rails server

The app will then be available at http://localhost:3000/

##### Testing

We use RSpec for tests. To run the test suite, run:

    bundle exec rspec

If you get the error `DATABASE_URL environment variable is set` you will need to remove the `DATABASE_URL` from the local .env file.

##### API / CORS

We are using the [rack-cors](https://github.com/cyu/rack-cors) gem.

CORS is configured in `config/initalisers/cors.rb` and the origins are defined by `ENV['CORS_ORIGINS']`.

##### Email notifications
Emails are created in the notifications table and delivered with delayed_job.
Until we have tested a full data set, it seemed wise to disable the sending of any broadcast emails.
To disable an email notification, override `Notification#deliverable?` e.g.

    def deliverable?
        false
    end

Automated reminder emails (system-generated) are generated daily. To defend against erroneous processes or bad data, they are created with an inital state of `pending_approval`. Before these emails can be sent, they need to marked as `approved` by a user. See the link `Automated Email Queue` in the top right navigation.

##### Email previews

Emails can be previewed at: /rails/mailers in development.

##### File Uploads
Files are uploaded with [paperclip](https://github.com/thoughtbot/paperclip) and store on Microsoft Azure. Ensure that the following credentials are set for each environment (except in :test, when the file storage is :filesystem).
`ENV['AZURE_STORAGE_ACCOUNT']`
`ENV['AZURE_ACCESS_KEY']`
`ENV['AZURE_CONTAINER_NAME']`
Refer to `config/initializers/paperclip.rb` for implementation.
Note that Private URLs are enabled and the file url should be generated with the helper method: `azure_private_asset_url`, found in `app/helpers/asset_helper.rb`.


##### SMS Notification
SMS Notifications are delivered by [Gov.UK Notify](https://www.notifications.service.gov.uk).
This is implemented in `app/services/sms_provider.rb`.
Ensure that the API key is set as `ENV['NOTIFY_API_KEY']`,
And the Template ID as `ENV['NOTIFY_TEMPLATE_ID']`.

##### Postcode Lookup
Postcode lookups are performed by a Javascript API call to https://ideal-postcodes.co.uk. The account is managed by the MCA and the code uses Ideal Postcode's [JQuery API](https://github.com/ideal-postcodes/jquery.postcodes).
Ensure that the API key is set as `POSTCODE_LOOKUP_API_KEY`

##### Cron jobs

Cron jobs are managed with the [whenever](https://github.com/javan/whenever) gem.

To ensure the crontab is kept up to date, ensure that `whenever --update-crontab` is called on deployment.

##### Referred applications

Schedule: Daily

If the `submission#referred_until` date has been reached, applications should be restored to the unclaimed tasks queue. To run this application_type:

  `rake waves:expire_referrals`


## Under the hood

#### Services
The services that can be performed are stored in the `services` table. Each service has:
1. A name
2. Service standard (standard_days or premium_days)
3. Pricing for the part / service standard
4. UI rules (e.g. validations, form display helpers)
5. Activities (e.g. generate_new_5_year_registration, update_registry_details)
6. Print templates (e.g. registration_certificate, cover_letter)

##### Submissions (aka Applications)
Submissions are requests to change something in the Registry of Ships. In the UI, we call them 'Applications' but in the Rails world, 'application' is a reserved word. A submission can be for a variety of different application types. The application type will determine whether a submission is for a registered vessel or a (flavour of) new registration.

The full list of application type can be retrieved from `ApplicationType.all_`. Note that the ApplicationType class references the WavesUtilities gem. It is also viewable in the admin section at: `http://localhost:3000/admin/application_types`.

Submissions have a state of `active` (aka `open`) or `closed`. A submission can be closed when all tasks have been completed or cancelled.

A registered vessel can have one `open` submission at a time.

##### How submissions are created
There are three points of entry for a submission:
1. Via a customer entry on the Online portal (submission#source `:online`)
2. Via Document Entry by a Reg Officer (submission#source `:manual_entry`)
3. Finance Team create Payments which are linked or converted to submissions by a Registration Officer.

When a submission enters the default :incomplete state, it fires an event `build_default`, invoking the `SubmissionBuilder` and setting up all the defaults. If you want to initialize a submission object to build a form or any other instance when you don't want a record to be created, you need to forecfully set the state to :initializing. For example: `Submission.new(state: :initializing)`.

##### Tasks
Submissions have many tasks (to be performed by a Reg Officer), and they travel through a state machine.
```
:initialising - Just added via the Task Manager, pending confirmation
:unclaimed - Confirmed by a Reg Officer. Target Dates have been assigned
:claimed - Add to a Reg Officer's Task Queue. Can be actionned.
:referred - Pending information from the customer.
:completed - Task is done. Activities have been performed. Print Jobs have been added to the Print Queue
:cancelled - Irreversible.
```

##### Task Behaviour
A task's behaviour depends on the Service, viewable within each part at: `http://localhost:3000/admin/services/processes`
1. Rules - define the page templates to display and validations to be applied.
2. Activities - describe what happens when the task is processed (`application_processor.rb`)
3. Print Templates - determine the printable outputs of a completed task

#### Work Logs
RSS require monitoring of staff performance, so actions such as completing or referring tasks are logged. There is a helper method available globally: `log_work!`.
Work logs can be viewed at: `http://localhost:3000/work_logs`

##### Submission Attributes
The changes that the submission will perform are stored as JSON objects in submission#changeset. If the submission is associated with a registered vessel, the 'current information' will be stored as JSON objects in submission#changeset.
These JSON objects are mounted with the `VirtualModel` class and exposed by the submission as: `submission.vessel`, etc.

##### Payments
Payments come in two flavours and have a polymorphic association with the `Payment` model.
1. World Pay Payments (online)
2. Finance Payments (manual_entry)

##### Declarations
In the submission context, we store owner details in the declarations table. The changes requested are stored as JSON objects in declaration#changeset. One owner maps to one declaration, and a submission can have many declarations.
Note that, while a changeset may contain `owners`, these are ignored once the `Builder::SubmissionBuilder` has run and the declarations have been built.

##### The Registry
The Registry consists of:
1. Registrations. The record of the current and previous registration details for a vessel.
2. Vessels. The current vessel record.
3. Owners. The current record of vessel owners.

##### Code structure
The app follows the standard Rails MVC pattern, additionally:
1. Builders are used to perform actions that create or update database records.
2. Decorators are used to add UI behaviour to the models.
3. Policies are user to answer questions: 'Can the submission be approved now?'
4. Services are used to encapsulate helper methods that don't make any database changes.

And mixins:
1. Concerns. Tried to limit the use of Active Record Concerns to functionality that was open to all models.
2. Submission mixins. The Submission class was getting too big for rubocop, so `app/model/submission/associations.rb` and  `app/model/submission/state_machine.rb` were extracted to modules. No reason other than code organization. Would welcome smart refactoring.

##### Search
Searching is helped along with [pg_search gem](https://github.com/Casecommons/pg_search).
To rebuild the (e.g. Submission) indexes after making changes to the configuration:
`PgSearch::Multisearch.rebuild(Submission)`
Global search configuration can be added to:
`config/initializers/pg_search.rb`

##### Extending the data model
Adding attributes to the data model can be a fairly complex process as there are a number of moving parts to consider. In the example below, we want to record the number of `shares_held` by an owner. If adding additional tables (e.g. groups of shareholders), be mindful that the table(s) will need to exist in both the `submission` domain and the `registry`.
1. Add a column `shares_held` to the `declarations` table. Note that `declarations` are the owners associated with a submission.
2. Build out the model, controller and views in Waves so that a reg officer can record the `shares_held` by an owner.
3. Add a column `shares_held` to the `customers` table. Note that all entities associated with a registered vessel are sub-classed from this table.
4. Extend `Builder::RegistryBuilder` to add the `shares_held` by an owner to the `customers` table.
5. Extend `Register::Vessel#registry_info` to ensure that the `shares_held` is captured. `#registry_info` is used to store a snapshot of the registered vessel in the `registrations` table. For our `shares_held` example we don't need to make any changes to `Register::Vessel#registry_info` because all owner attributes are assigned by default: `owners: owners.map(&:attributes)`
6. If the new data attribute will *not* be stored and edited in the `Submission#changeset` (i.e. it's not vessel_info), then extend `Builder::SubmissionBuilder` or `Builder::DeclarationBuilder` to enable the new attribute. For our `shares_held` example, we add the line `shares_held: owner[:shares_held].to_i` to `Builder::DeclarationBuilder#build_declarations`.
7. The `shares_held` name / value should also be added somewhere on the registered vessel page (`app/views/vessels`).
