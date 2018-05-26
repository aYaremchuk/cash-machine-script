Cash machine script
========
This is script created on ruby to imitate work of cash machine.

It uses yml file as database.

You can run it with your own yml file with data but for example you can use config.yml file included in repo.

### Basic system specs:

- Ruby 2.5.0


### Configuration:

* bundle install
* ruby cash_machine.rb **config.yml**

You can use your own file instead of config.yml but be sure that structure of data is the same as in example file.

### Tests
* ruby test/withdraw_sercive.rb
