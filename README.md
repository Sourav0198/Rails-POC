# rails-poc

- Created the Project using comamnd - rails new rails-poc --api -d mysql
- Application is using mysql database.

-For Running the Applicaition first setup the db:
- To create a db, use the command -  *rails db:create*


-To update the db or want to sync the db: 
 - Use - *rails db:migrate*


-To setup the mailhog in ubuntu,follow the steps:

     # Install Go (if not already installed)
        -sudo apt update
        -sudo apt install golang-go

    # Install MailHog
        -go get github.com/mailhog/MailHog
        -go install github.com/mailhog/MailHog

    # Start MailHog:
        -MailHog or ~/go/bin/MailHog
    MailHog Console runs at - http://localhost:8025


    #For the test cases , we are using Rspec 
     For Setup - Add this to gemfile if not added -> *gem 'rspec-rails', '~> 6.0.0'*
            - To create spec first time if spec folder not created - rails generate rspec:install
     To run test - *bundle exec rspec*
     
