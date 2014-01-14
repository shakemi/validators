#!/bin/sh

## this script probably runs only on a Linux-based machine
## you need CVS, Java and ant to be already installed

# check out the source
if [ ! -d 2002 ]; then
    export CVSROOT=":pserver:anonymous@dev.w3.org:/sources/public"
    echo
    echo "IMPORTANT: enter anonymous as the password for cvs"
    echo
    cvs login
    cvs get 2002/css-validator
    # fix for an issue with the Velocity templates
    sed -i '/Velocity.getLog/i }' ./2002/css-validator/org/w3c/css/index/IndexGenerator.java
    sed -i '/For each language, we set the context/i if(false) {' ./2002/css-validator/org/w3c/css/index/IndexGenerator.java

    # add VelocityTools
    BUILD_XML="./2002/css-validator/build.xml"

    REGEXP='<available file="lib\/velocity-1.7.jar"\/>'
    REPLACEMENT='        <available file="lib\/velocity-tools-2.0.jar"\/>'
    sed -i "/$REGEXP/ {s/.*/&\n$REPLACEMENT/;}" $BUILD_XML

    REGEXP='    <get dest="tmp\/velocity-1.7.tar.gz" src="http:\/\/www.apache.org\/dist\/velocity\/engine\/1.7\/velocity-1.7.tar.gz" usetimestamp="true"\/>'
    REPLACEMENT='    <get dest="tmp\/velocity-tools-2.0.jar" src="http:\/\/www.apache.org\/dist\/velocity\/tools\/2.0\/velocity-tools-2.0.jar" usetimestamp="true"\/>'
    sed -i "/$REGEXP/ {s/.*/&\n$REPLACEMENT/;}" $BUILD_XML

    REGEXP='    <copy file="tmp\/velocity-1.7\/velocity-1.7.jar" tofile="lib\/velocity-1.7.jar"\/>'
    REPLACEMENT='    <copy file="tmp\/velocity-tools-2.0.jar" tofile="lib\/velocity-tools-2.0.jar"\/>'
    sed -i "/$REGEXP/ {s/.*/&\n$REPLACEMENT/;}" $BUILD_XML

    REGEXP='        <attribute name="Class-path" value=". lib\/commons-collections-3.2.1.jar lib\/commons-lang-2.6.jar lib\/jigsaw.jar lib\/tagsoup-1.2.jar lib\/velocity-1.7.jar lib\/xercesImpl.jar lib\/xml-apis.jar lib\/htmlparser-1.3.1.jar"\/>'
    REPLACEMENT='        <attribute name="Class-path" value=". lib\/commons-collections-3.2.1.jar lib\/commons-lang-2.6.jar lib\/jigsaw.jar lib\/tagsoup-1.2.jar lib\/velocity-1.7.jar lib\/velocity-tools-2.0.jar lib\/xercesImpl.jar lib\/xml-apis.jar lib\/htmlparser-1.3.1.jar"\/>'
    sed -i "/$REGEXP/ {s/.*/$REPLACEMENT/;}" $BUILD_XML
fi;

# build the jar file
cd 2002/css-validator
ant
ant jar

# stages the jar and templates so that it's part of the SBT project
cd ../..
echo copying the jar and other files
cp 2002/css-validator/css-validator.jar lib
mkdir -p src/main/resources/org/w3c/css/index src/main/resources/org/w3c/css/css
cp 2002/css-validator/*html* src/main/resources/org/w3c/css/index
cp 2002/css-validator/org/w3c/css/index/*.vm src/main/resources
