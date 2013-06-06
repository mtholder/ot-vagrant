opentree vagrant
################
This repo has the input files needed to bootstrap a vagrant ( http://www.vagrantup.com/ ) virtual
machine with the opentree of life software tools

Installation
############
After installing vagrant, 

    $ cp set-up-web2py-user.mysql.txt.Example set-up-web2py-user.mysql.txt

Then edit set-up-web2py-user.mysql.txt if you want to change the db passwords used by the web apps

    $ vagrant up
    $ vagrant ssh
