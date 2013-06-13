sudo apt-get install git
git clone git://github.com/mtholder/ot-vagrant.git
cd ot-vagrant/
git pull origin 
cat >web2py_passwords.sh <<ENDOFHEREDOC
#!/bin/sh
export WEB2PY_DB_USER=w2puser
export WEB2PY_DB_PASSWD=1a2b3c

ENDOFHEREDOC
starttime=$(date)
bash nonvagrant-bootstrap.sh 

cp -r opentree-tools nonvagrant-user/open-tree/opentree-tools

cat > opentree_to_source.sh <<ENDOFHEREDOC2
#!/bin/sh
source $PWD/nonvagrant-user/opentree-shell.sh
export TAXOMACHINE_JAVA_OPTS="-enableassertions"
export TREEMACHINE_JAVA_OPTS="-enableassertions"
export TAXOMACHINE_PROPERTIES="-Dlog4j.configuration=${TAXOMACHINE_ROOT}/debuglog4j.properties"
export TREEMACHINE_PROPERTIES="-Dlog4j.configuration=${TREEMACHINE_ROOT}/debuglog4j.properties"
export PATH="\$PATH":"$PWD/nonvagrant-user/open-tree/opentree-tools/bin"
ENDOFHEREDOC2
cat auto-complete.sh >> opentree_to_source.sh 

echo started at:
echo $starttime
echo ended at:
date

