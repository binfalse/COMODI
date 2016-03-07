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

echo thisVersionURI=http://purl.uni-rostock.de/comodi/$TODAY >> $config
echo latestVersionURI=http://purl.uni-rostock.de/comodi/ >> $config
echo previousVersionURI=http://purl.uni-rostock.de/comodi/$previous >> $config
echo dateOfRelease=$TODAY >> $config
echo dateOfRelease=$TODAY >> $config
echo ontologyRevisionNumber=$TODAY >> $config

############
echo "running widoco -- see https://github.com/dgarijo/Widoco"
#[-ontFile file] or [-ontURI uri] [-outFolder folderName] [-confFile propertiesFile] or [-getOntologyMetadata] [-oops] [-rewriteAll] [-saveConfig configOutFile]
java -jar widoco-0.0.1-jar-with-dependencies.jar -ontFile $ONTOFILE -confFile $config -outFolder $OUTDIR

echo ''
echo ''
echo ''
echo ''
echo ".... done with widoco"

echo "updating files, using templates in $TEMPLATES"
# copy abstract
echo "abstract ..."
cp $TEMPLATES/abstract.html $OUTDIR/sections/abstract-en.html

# copy intro
echo "intro ..."
cp $TEMPLATES/introduction.html $OUTDIR/sections/introduction-en.html

# replace in overview: <p>Overview of the ontology goes here: a few sentences explaining the main concepts of the ontology</p>
echo "overview ..."
tmp=$(mktemp)
cp $TEMPLATES/overview.html $tmp
tail -n+3 $OUTDIR/sections/overview-en.html | sed 's/##/#/g' >> $tmp
cp $tmp $OUTDIR/sections/overview-en.html

# copy description
echo "description ..."
cp $TEMPLATES/description.html $OUTDIR/sections/description-en.html

# fix links in crossref
echo "crossref ..."
cat $OUTDIR/sections/crossref-en.html | sed 's/##/#/g' | sed 's/id="#/id="/' > $tmp
cp $tmp $OUTDIR/sections/crossref-en.html

# copy references
echo "references ..."
cp $TEMPLATES/references.html $OUTDIR/sections/references-en.html

# update acknoledgements
echo "acknowledgements ..."
head -n-6 $OUTDIR/index-en.html | sed 's%<script src="resources/jquery.js"></script>%<script src="resources/jquery.js"></script><script src="resources/js.js"></script><link rel="stylesheet" href="resources/css.css"/>%' > $tmp
cat $TEMPLATES/acknowledgements.html >> $tmp
cp $tmp $OUTDIR/index-en.html
# ln -s index-en.html $OUTDIR/index.html

# copy js and css
cp $TEMPLATES/js.js $OUTDIR/resources/js.js
cp $TEMPLATES/css.css $OUTDIR/resources/css.css

# copy the current version of the image into the current release
# [ -f ../doc/whole-incl-links.svg ] && cp ../doc/whole-incl-links.svg $OUTDIR/whole.svg || 
cp ../doc/whole.svg $OUTDIR/whole.svg

# embedding files
echo "embedding files"
/bin/grep -B 1000 '<div id="abstract"></div>' $OUTDIR/index-en.html | /bin/grep -v ').load("sections/' | /bin/grep -v '>Revision:<' | /bin/grep -v 'property="schema:version">' | sed 's/<head>/<head><title>COMODI<\/title>/' |  sed 's/><\/img>/ \/>/' | head -n -1 > $OUTDIR/index.html
echo '<div id="abstract">' >> $OUTDIR/index.html
cat $OUTDIR/sections/abstract-en.html >> $OUTDIR/index.html
echo '</div>
<div id="toc"><h2>Table of contents</h2>
<ul>
<li><a href="#introduction">1. Introduction</a></li>
<ul><li><a href="#namespacedeclarations">1.1 Namespace declarations</a></li></ul>
<li><a href="#overview">2. COMODI: Overview</a></li>
<li><a href="#description">3. COMODI: Description</a></li>
<li><a href="#crossref">4. Cross reference for COMODI classes, properties and dataproperties</a></li>
<ul>
<li><a href="#classes">4.1 Classes</a></li>
<li><a href="#objectproperties">4.2 Object Properties</a></li>
        <li><a href="#dataproperties">4.3 Data Properties</a></li>
</ul>
<li><a href="#references">5. References</a></li>
<li><a href="#acknowledgements">6. Acknowledgements</a></li>
</ul>
</div>' >> $OUTDIR/index.html

echo '<div id="introduction">' >> $OUTDIR/index.html
cat $OUTDIR/sections/introduction-en.html >> $OUTDIR/index.html
echo '</div><div id="overview">' >> $OUTDIR/index.html
cat $OUTDIR/sections/overview-en.html >> $OUTDIR/index.html
echo '</div><div id="description">' >> $OUTDIR/index.html
cat $OUTDIR/sections/description-en.html >> $OUTDIR/index.html
echo '</div><div id="crossref">' >> $OUTDIR/index.html
cat $OUTDIR/sections/crossref-en.html >> $OUTDIR/index.html
echo '</div><div id="references">' >> $OUTDIR/index.html
cat $OUTDIR/sections/references-en.html >> $OUTDIR/index.html
echo '</div>' >> $OUTDIR/index.html
/bin/grep -A 1000 '<div id="references"></div>' $OUTDIR/index-en.html | tail -n +2 >> $OUTDIR/index.html


# linking
echo "doing link infrastructure"
[ -e latest ] && rm latest
ln -s $OUTDIR latest


# publishing owl file
echo "copying owl file"
cp $ONTOFILE $OUTDIR/

##########
echo "done. have a look into $TODAY"

