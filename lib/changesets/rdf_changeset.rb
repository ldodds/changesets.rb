module RDF
  module Talis
    class Changeset < RDF::Vocabulary('http://purl.org/vocab/changeset/schema#')
      property :removal
      property :addition
      property :creatorName
      property :createdDate
      property :subjectOfChange
      property :changeReason
      property :ChangeSet
      property :precedingChangeSet
    end
  end
end

module RDF
    
  class Changeset

    #Media type for Changesets
    CONTENT_TYPE_TURTLE = "application/vnd.talis.changeset+turtle"
    CONTENT_TYPE_XML = "application/vnd.talis.changeset+xml"
    #Default reason for applying the update to a graph
    DEFAULT_REASON = "Generated in changeset.rb"
    #Default name/label for the change agent
    DEFAULT_CREATOR = "changeset.rb"
    
    attr_reader :statements, :subject_of_change
    
    def initialize(subject_of_change, change_reason=DEFAULT_REASON, creator_name=DEFAULT_CREATOR)
      @resource = RDF::Node.new
      @subject_of_change = subject_of_change
      @statements = []
      @statements.concat [RDF::Statement.new(@resource, RDF.type, RDF::Talis::Changeset.ChangeSet),
       RDF::Statement.new(@resource, RDF::Talis::Changeset.changeReason, change_reason),
       RDF::Statement.new(@resource, RDF::Talis::Changeset.creatorName, creator_name),
       RDF::Statement.new(@resource, RDF::Talis::Changeset.createdDate, Time.now),
       RDF::Statement.new(@resource, RDF::Talis::Changeset.subjectOfChange, subject_of_change)]
       if block_given?
         yield self
       end
    end
    
    #Remove these statements from the graph
    def remove_statements(stmts)
      stmts = [stmts] if stmts.is_a?(RDF::Statement)
      stmts.each do |stmt|
        raise ArgumentError unless stmt.subject == @subject_of_change        
        @statements.concat changeset_statement(stmt, :removal)
      end
    end
    
    #Add these statements to the graph
    def add_statements(stmts)
      stmts = [stmts] if stmts.is_a?(RDF::Statement)
      stmts.each do |stmt|
        next unless stmt
        raise ArgumentError unless stmt.subject == @subject_of_change        
        @statements.concat changeset_statement(stmt, :addition)
      end
    end
        
    def changeset_statement(stmt, action)
      s = RDF::Node.new
      [RDF::Statement.new(@resource, RDF::Talis::Changeset.send(action), s),
        RDF::Statement.new(s, RDF.type, RDF.to_rdf+"Statement"),
        RDF::Statement.new(s, RDF.subject, stmt.subject),
        RDF::Statement.new(s, RDF.predicate, stmt.predicate),
        RDF::Statement.new(s, RDF.object, stmt.object)]
    end    
    
    #Convert into an RDF::Graph object
    def to_graph
      graph = RDF::Graph.new()
      @statements.each do |s|
        graph << s
      end
      graph
    end
            
    #Update a predicate from one value to another
    #Will only remove the specified old value, other values for predicate will remain unchanged
    def Changeset.update_property(subject, predicate, old_value, new_value, change_reason=DEFAULT_REASON, creator_name=DEFAULT_CREATOR)
      cs = Changeset.new(subject, change_reason, creator_name) do |cs|
        cs.remove_statements( RDF::Statement.new( subject, predicate, old_value ) )
        cs.add_statements( RDF::Statement.new( subject, predicate, new_value ) )        
      end
      cs
    end
        
    #Remove a specific single property for a subject
    def Changeset.remove_property(subject, predicate, value, change_reason=DEFAULT_REASON, creator_name=DEFAULT_CREATOR)
      return Changeset.remove_statement( RDF::Statement.new( subject, predicate, value ) )
    end

    #Remove a statement
    def Changeset.remove_statement( statement, change_reason=DEFAULT_REASON, creator_name=DEFAULT_CREATOR)
      cs = Changeset.new(statement.subject, change_reason, creator_name) do |cs|
        cs.remove_statements( statement )
      end
      cs
    end
    
    #Remove all statements with a specific predicate for a specific resource
    def Changeset.remove_properties(subject, predicate, graph, change_reason=DEFAULT_REASON, creator_name=DEFAULT_CREATOR)
      cs = Changeset.new(subject, change_reason, creator_name) do |cs|
        graph.query( [subject, predicate, nil] ).each do |statement|
          cs.remove_statements( statement )
        end              
      end                  
      cs
    end
    
    #Remove all statements where the indicated resource is the subject
    def Changeset.remove_subject(subject, graph, change_reason=DEFAULT_REASON, creator_name=DEFAULT_CREATOR)
      cs = Changeset.new(subject, change_reason, creator_name) do |cs|
        graph.query( [subject, nil, nil] ).each do |statement|
          cs.remove_statements( statement )
        end              
      end                  
      cs      
    end
    
    #Apply an update by removing all statements for the indicated subject from the old graph, replacing it 
    #with statements in the new graph    
    def Changeset.update(subject, new, old, change_reason=DEFAULT_REASON, creator_name=DEFAULT_CREATOR)
      cs = Changeset.new(subject, change_reason, creator_name) do |cs|
        old.query( [subject, nil, nil] ).each do |statement|
          cs.remove_statements( statement )
        end        
        new.query( [subject, nil, nil] ).each do |statement|
          cs.add_statements( statement )
        end
      end      
      cs
    end
    
  end
end