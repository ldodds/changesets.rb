CHANGESET.RB
------------

A plugin for RDF.rb that provides support for creating Changesets that describe changes to an RDF 
graph[1]. 

Changesets can be serialized as RDF and then applied to a triple store. Changesets are currently supported 
by Talis Platform stores and Kasabi[0] datasets.

AUTHOR
------

Leigh Dodds (ld@kasabi.com)

INSTALLATION
------------

Changesets.rb is packaged as a Ruby Gem and can be installed as follows:

	sudo gem install changesets
	
The source for the project is maintained in github at:

http://github.com/ldodds/changesets.rb

USAGE
-----

The test suite provides some simple examples of how to construct changesets.

[0]: [http://kasabi.com]
[1]: [http://vocab.org/changeset/schema.html]