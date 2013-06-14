opentree vagrant
################
*NOTE* These scripts are intended to be run on an expendable virtual machine - not some machine that you know and love. See the disclaimer of any warranty in the license file

This repo has the input files needed to bootstrap a vagrant ( http://www.vagrantup.com/ ) virtual machine with the opentree of life software tools. MTH has tested this with VirtualBox ( https://www.virtualbox.org/ ). It is not working there, due to memory-heavy processed getting killed.

I have unning Ubuntu 12.04 Updated NoGUI v1

*NOTE* the mysql passwords are in plain text in the bootstrap file, so this should not be used for an outward-facing deployment. The default deployment should allow you to connect only via the host machine, so is should not introduce a security hole in your host machine.

Installation
############

In this directory with this README and the bootstrap.sh file add a file with something like the 
following text with the name "web2py_passwords.sh"

    export WEB2PY_DB_USER=tester
    export WEB2PY_DB_PASSWD=abc123

After installing vagrant, the commands for booting the virtual machine and logging in are:

    $ vagrant up
    $ vagrant ssh

Launching software
##################

To launch phylografter:

    $ cd $OPEN_TREE/web2py
    $ echo 'your preferred web2py admin password here' | python web2py.py --nogui -i 192.168.33.10 & 

or:

    $ python web2py.py --nogui -a '<recycle>' -i 192.168.33.10 & 

if you have previously launched web2py and entered an admin password. 192.168.33.10 is the
IP listed in the Vagrantfile as the virtual machine's IP. After doing this, you should be able to see
open tree software at http://192.168.33.10:8000/phylografter and  http://192.168.33.10:8000/opentree

If you need to have access to the admin section of web2py, launch it without the -i and IP address.
This will cause web2py to bind to the loopback (localhost, or 127.0.0.1) address. Then you can
 log out of the virtual machine and use:

    $ vagrant ssh -- -L 8000:127.0.0.1:8000

to establish an ssh tunnel from port 8000 on the host machine to port 8000 on the virtual machine.
This should give you open tree services at http://127.0.0.1:8000/phylografter http://127.0.0.1:8000/opentree



These scripts are released under a BSD-style License (see License.txt)

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
