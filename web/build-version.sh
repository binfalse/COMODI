#!/bin/bash

ONTOFILE=../ontology/comodi.owl
TODAY=$(date +%F)
OUTDIR=$TODAY
CONF=widoco-conf
TEMPLATES=template

##############
echo "ONTOLOGY RELEASER..."
echo "realeasing onotlogy $ONTOFILE in $OUTDIR"

if [ -e $OUTDIR ]
then
    echo ">> dir $OUTDIR exists. will not overwrite"
    exit 2
fi



###############

previous=$(/bin/ls -ld 2* | /bin/grep '^d' | tail -1 | awk '{print $9}' | sed 's/\///')
config=$(mktemp)
mkdir -p $OUTDIR

##############
echo "template configuration in $CONF"
echo "will be copied to and adjusted in $config"
echo "previous versions was $previous"

cat $CONF | /bin/grep -v VersionURI | /bin/grep -v dateOfRelease | /bin/grep -v ontologyRevisionNumber > $config

echo thisVersionURI=http://purl.org/net/comodi/$TODAY >> $config
echo latestVersionURI=http://purl.org/net/comodi >> $config
echo previousVersionURI=http://purl.org/net/comodi/$previous >> $config
echo dateOfRelease=$TODAY >> $config
echo dateOfRelease=$TODAY >> $config
echo ontologyRevisionNumber=$TODAY >> $config

############
echo "running widoco -- see https://github.com/dgarijo/Widoco"
#[-ontFile file] or [-ontURI uri] [-outFolder folderName] [-confFile propertiesFile] or [-getOntologyMetadata] [-oops] [-rewriteAll] [-saveConfig configOutFile]
java -jar widoco-0.0.1-jar-with-dependencies.jar -ontFile $ONTOFILE -confFile $config -outFolder $OUTDIR

echo ""
echo ""
echo ""
echo ""
echo ".... done with widoco"

echo "updating files, using templates in $TEMPLATES"
# copy abstract
echo "abstract ..."
cp $TEMPLATES/abstract.html $OUTDIR/sections

# copy intro
echo "intro ..."
cp $TEMPLATES/introduction.html $OUTDIR/sections

# replace in overview: <p>Overview of the ontology goes here: a few sentences explaining the main concepts of the ontology</p>
echo "overview ..."
tmp=$(mktemp)
cp $TEMPLATES/overview.html $tmp
tail -n+3 $OUTDIR/sections/overview.html | sed 's/##/#/g' >> $tmp
cp $tmp $OUTDIR/sections/overview.html

# copy description
echo "description ..."
cp $TEMPLATES/description.html $OUTDIR/sections

# fix links in crossref
echo "crossref ..."
cat $OUTDIR/sections/crossref.html | sed 's/##/#/g' | sed 's/id="#/id="/' > $tmp
cp $tmp $OUTDIR/sections/crossref.html

# copy references
echo "references ..."
cp $TEMPLATES/references.html $OUTDIR/sections

# update acknoledgements
echo "acknowledgements ..."
head -n-6 $OUTDIR/index.html > $tmp
cat $TEMPLATES/acknowledgements.html >> $tmp
cp $tmp $OUTDIR/index.html



# linking
echo "doing link infrastructure"
[ -e latest ] && rm latest
ln -s $OUTDIR latest


# publishing owl file
echo "copying owl file"
cp $ONTOFILE $OUTDIR/

##########
echo "done. have a look into $TODAY"

