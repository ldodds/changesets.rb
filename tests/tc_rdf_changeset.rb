$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'changesets'
require 'test/unit'
require 'mocha'

class ChangesetTest < Test::Unit::TestCase
  
  def test_init
    cs = RDF::Changeset.new( RDF::URI.new("http://www.example.org") )
    assert_equal( RDF::URI.new("http://www.example.org"), cs.subject_of_change )
    assert_equal( false, cs.statements.empty? )
    
    graph = cs.to_graph()
    assert_not_nil( graph )
    assert_equal( cs.statements.length, cs.to_graph.size )
  end
  
  def test_add_single_statement
    uri = RDF::URI.new("http://www.example.org")
    cs = RDF::Changeset.new( uri  )
    stmts = RDF::Statement.new( uri , RDF.type, RDF::RDFS.Class )       
    cs.add_statements( stmts )    
    test_for( RDF::Talis::Changeset.addition, cs, stmts )
  end

  def test_remove_single_statement
    uri = RDF::URI.new("http://www.example.org")
    cs = RDF::Changeset.new( uri  )
    stmts = RDF::Statement.new( uri , RDF.type, RDF::RDFS.Class )
    cs.remove_statements( stmts )       
    test_for( RDF::Talis::Changeset.removal, cs, stmts )
  end
    
  def test_add_statements
    uri = RDF::URI.new("http://www.example.org")
    cs = RDF::Changeset.new( uri  )    
    stmts = [ RDF::Statement.new( uri , RDF.type, RDF::RDFS.Class ) ]
    cs.add_statements( stmts )             
    test_for( RDF::Talis::Changeset.addition, cs, stmts )    
  end  
  
  def test_remove_statements
    uri = RDF::URI.new("http://www.example.org")
    cs = RDF::Changeset.new( uri  )
    stmts = [ RDF::Statement.new( uri , RDF.type, RDF::RDFS.Class ) ]   
    cs.remove_statements( stmts )    
    test_for( RDF::Talis::Changeset.removal, cs, stmts )    
  end  
    
  def test_precondition
    uri = RDF::URI.new("http://www.example.org")
    other = RDF::URI.new("http://www.example.com")
    cs = RDF::Changeset.new( uri  )
    
    assert_raise ArgumentError do
      cs.add_statements( RDF::Statement.new( other , RDF.type, RDF::RDFS.Class ) )
    end
    assert_raise ArgumentError do
      cs.remove_statements( RDF::Statement.new( other , RDF.type, RDF::RDFS.Class ) )
    end
        
  end
  
  def test_update_property()
    uri = RDF::URI.new("http://www.example.org")
    cs = RDF::Changeset.update_property(uri, RDF::RDFS.label, RDF::Literal.new("Old"), RDF::Literal.new("New") )
    removal = RDF::Statement.new( uri, RDF::RDFS.label, RDF::Literal.new("Old"))
    addition = RDF::Statement.new( uri, RDF::RDFS.label, RDF::Literal.new("New"))
    test_for( RDF::Talis::Changeset.removal, cs, removal )
    test_for( RDF::Talis::Changeset.addition, cs, addition )
  end

  def test_remove_property()
    uri = RDF::URI.new("http://www.example.org")
    cs = RDF::Changeset.remove_property(uri, RDF::RDFS.label, RDF::Literal.new("Gone") )
    removal = RDF::Statement.new( uri, RDF::RDFS.label, RDF::Literal.new("Gone"))
    test_for( RDF::Talis::Changeset.removal, cs, removal )
  end

  def test_remove_statement()
    uri = RDF::URI.new("http://www.example.org")
    removal = RDF::Statement.new( uri, RDF::RDFS.label, RDF::Literal.new("Gone") )
    cs = RDF::Changeset.remove_statement( removal )    
    test_for( RDF::Talis::Changeset.removal, cs, removal )
  end
  
  def test_remove_properties()
    uri = RDF::URI.new("http://www.example.org")
    graph = RDF::Graph.new()
    label = RDF::Statement.new( uri, RDF::RDFS.label, RDF::Literal.new("Label") )
    title = RDF::Statement.new( uri, RDF::RDFS.label, RDF::Literal.new("Title") )
    graph << label
    graph << title
    cs = RDF::Changeset.remove_properties(uri, RDF::RDFS.label, graph )
    #puts cs.statements
    test_for( RDF::Talis::Changeset.removal, cs, label )    
    test_for( RDF::Talis::Changeset.removal, cs, title )
  end

  def test_remove_subject()
    uri = RDF::URI.new("http://www.example.org")
    graph = RDF::Graph.new()
    label = RDF::Statement.new( uri, RDF::RDFS.label, "Label")
    title = RDF::Statement.new( uri, RDF::DC.title, "Title")
    graph << label
    graph << title
    cs = RDF::Changeset.remove_subject(uri, graph )
    test_for( RDF::Talis::Changeset.removal, cs, [ label, title ] )    
  end
              
  def test_update()
    uri = RDF::URI.new("http://www.example.org")
    graph = RDF::Graph.new()
    label = RDF::Statement.new( uri, RDF::RDFS.label, "Label")
    title = RDF::Statement.new( uri, RDF::DC.title, "Title")
    graph << label
    graph << title
    cs = RDF::Changeset.update(uri, RDF::Graph.new(), graph )
    test_for( RDF::Talis::Changeset.removal, cs, [ label, title ] )        
      
    cs = RDF::Changeset.update(uri, graph, RDF::Graph.new() )
    test_for( RDF::Talis::Changeset.addition, cs, [ label, title ] )              
  end

#  def test_apply_to()
#    uri = RDF::URI.new("http://www.example.org")
#    graph = RDF::Graph.new()
#    label = RDF::Statement.new( uri, RDF::RDFS.label, RDF::Literal.new("Label") )
#    title = RDF::Statement.new( uri, RDF::DC.title, RDF::Literal.new("Title") )
#    graph << label
#    graph << title
#    cs = RDF::Changeset.remove_properties(uri, RDF::RDFS.label, graph )
#    
#    cs.apply_to(graph)    
#    
#    label = graph.first_object( [uri, RDF::RDFS.label, nil ] )
#    assert_nil(label)
#  end

      
  def test_for( predicate, cs, statements )
    statements = [statements] if statements.is_a?(RDF::Statement)
    
    statements.each do |s|
      query = RDF::Query.new do
        pattern [ :x, predicate, :stmt ]
        pattern [ :stmt, RDF.subject, s.subject]
        pattern [ :stmt, RDF.predicate, s.predicate]
        pattern [ :stmt, RDF.object, s.object]
      end
      query.execute(cs.to_graph)
      if query.failed?
        raise "Unable to find #{predicate} for #{s.subject} #{s.predicate}, #{s.object}"
      end
    end
  end
  
end