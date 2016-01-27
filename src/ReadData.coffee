require 'papaparse'

column_name_map =
    perform_tasks        : "He/she performs the required tasks of the assigned role excellently."
    is_dilligent         : "He/she is dilligent and detail oriented in performing the role assigned."
    is_works_well        : "He/she is works well with others and hands off a clean product for the next person in the production chain."
    commits_to_deadlines : "He/she commits to clear deadlines and upholds them consistently."
    right_intensity      : "He/she demonstrates the right intensity and personal commitment in trying to produce the best work product possible in as little time as possible"
    seeks_feedback       : "He/she proactively seeks out feedback and acts on constructive feedback to grow and learn."
    lives_culture        : "He/she lives the culture of Bully and contributes to making the company great."
    is_helping_others    : "He/she is helping others grow and learn"
    build_needed_systems : "He/she is helping to build the needed systems, processes and structure for the company to be able to grow successfully	Comments"

class DataReader
    load_from_url: (url) ->
        console.log "Load data from #{url}"

class Response
    constructor: (@name, data) ->
        



module.exports =
    read_data : (url) ->
       reader = new DataReader()
       reader.load_from_url url
