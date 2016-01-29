Papa = require 'papaparse'

slice_marker = "Want to save and continue later? - click below"

column_name_map = {

    timestamp: {
        text: "Timespamp",
        has_comment: false
    },
    your_name : {
        text: "Please provide your full name.",
        has_comment: false
    },
    perform_tasks        : {
        text: "He/she performs the required tasks of the assigned role excellently.",
        has_comment: true },
    is_dilligent         : {
        text: "He/she is dilligent and detail oriented in performing the role assigned.",
        has_comment: true },
    is_works_well        : {
        text: "He/she is works well with others and hands off a clean product for the next person in the production chain.",
        has_comment: true },
    commits_to_deadlines : {
        text: "He/she commits to clear deadlines and upholds them consistently.",
        has_comment: true },
    right_intensity      : {
        text: "He/she demonstrates the right intensity and personal commitment in trying to produce the best work product possible in as little time as possible",
        has_comment: true },
    seeks_feedback       : {
        text: "He/she proactively seeks out feedback and acts on constructive feedback to grow and learn.",
        has_comment: true },
    lives_culture        : {
        text: "He/she lives the culture of Bully and contributes to making the company great.",
        has_comment: true },
    is_helping_others    : {
        text: "He/she is helping others grow and learn",
        has_comment: true },
    build_needed_systems : {
        text: "He/she is helping to build the needed systems, processes and structure for the company to be able to grow successfully",
        has_comment: true },
}

bully_columns = {
    i_see_myself: {text: "I see myself working at Bully in five years from now.", has_comment: true},
    bully_is_a_great: {text: "Bully is a great place to work", has_comment: true},
    my_coworkers: {text: "My co-workers at the company are highly qualified and committed to the goal of producing world-class products.", has_comment: true},
    i_feel_challenged: {text: "I feel challeneged at my work and constantly learn new things.", has_comment: true},
    well_managed: {text: "Bully is a well managed company.", has_comment: true},
    understand_goals: {text: "I understand what the goals of the company are.", has_comment: true},
    over_next_two_years: {text: "Over the next 2-3 years what are the the things you want to learn/explore; what additional responsibilities would you like to assume?", has_comment: false},
    ideas_tips: {text: "What ideas, tips, feedback do you have for Bully?", has_comment: false},
}

member_columns = {

    interaction_freq : { text: "How much have you interacted with the person being reviewed?", has_comment: false},
    is_anonym : { text: "Do you want the feedback for this person to be anonymous?", has_comment: false},
    perform_tasks        : {
        text: "He/she performs the required tasks of the assigned role excellently.",
        has_comment: true },
    is_dilligent         : {
        text: "He/she is dilligent and detail oriented in performing the role assigned.",
        has_comment: true },
    is_works_well        : {
        text: "He/she is works well with others and hands off a clean product for the next person in the production chain.",
        has_comment: true },
    commits_to_deadlines : {
        text: "He/she commits to clear deadlines and upholds them consistently.",
        has_comment: true },
    right_intensity      : {
        text: "He/she demonstrates the right intensity and personal commitment in trying to produce the best work product possible in as little time as possible",
        has_comment: true },
    seeks_feedback       : {
        text: "He/she proactively seeks out feedback and acts on constructive feedback to grow and learn.",
        has_comment: true },
    lives_culture        : {
        text: "He/she lives the culture of Bully and contributes to making the company great.",
        has_comment: true },
    is_helping_others    : {
        text: "He/she is helping others grow and learn",
        has_comment: true },
    build_needed_systems : {
        text: "He/she is helping to build the needed systems, processes and structure for the company to be able to grow successfully",
        has_comment: true },
}

get_separators_indicies = (headers, separator) ->
    marker_positions = []

    marker_positions = (idx for idx in headers when headers[idx] == separator)

    #for idx = 0; idx < headers.length; idx++
    #{
        #if (headers[idx] == separator)
        #{
            #marker_positions.push(idx)
        #}
    #}
    marker_positions

split_array = (array, split_indexes) ->
    slices = []
    begin = 0

    for sep_idx in split_indexes
        slices.push( array.slice(begin, split_indexes[sep_idx]) )
        begin = split_indexes[sep_idx] + 1

    slices

remove_redudant_columns = (data, indicies) ->
    console.log("Indicies length before: " + indicies.length)

    # remove indicies placed at odd positions in this array.
    indicies = indicies.filter (item, index) -> (index % 2 != 0)

    console.log "Indicies length after: " + indicies.length

    for _, i in data.data
        data.data[i] = data.data[i].filter (item, index) ->
            indicies.indexOf(index) == -1


read_self_evaluation = (data) ->
    obj = {}
    idx = 0

    # Read all the rest fields
    for prop in column_name_map
        field = column_name_map[prop]
        if field.has_comment
            obj[prop] = {
                score: data[idx++],
                comment: data[idx++]
            }
        else
            obj[prop] = data[idx++]
    obj


read_evaluation = (fields, data) ->
    obj = {}
    idx = 0

    # Read all the rest fields
    for prop in fields

         field = fields[prop]

        if field.has_comment
            obj[prop] = {
                score: data[idx++],
                comment: data[idx++]
            }
        else
            obj[prop] = data[idx++]
    obj

parse_responses = (data) ->
    #global variable
    response_split_indicies = get_separators_indicies(data.data[0], slice_marker)
    console.log "Separator indicies : " + response_split_indicies
    #Skip first 3 
    remove_redudant_columns(data, response_split_indicies.slice(1))

    # Get new split indicies.
    response_split_indicies = get_separators_indicies(data.data[0], slice_marker)

    my_response = split_array(data.data[1], response_split_indicies)

    self_eval = read_evaluation(column_name_map, my_response[0])
    bully     = read_evaluation(bully_columns, my_response[1])
    next_user = read_evaluation(member_columns, my_response[2])

    console.log(my_response[2])
    console.log(next_user)
    my_response


substitute_headers = (text) ->
    for item in column_name_map
        text = text.replace(new RegExp(column_name_map[item].text, 'g'), item)
    text


read_responses = (text) ->
    text = substitute_headers(text)
    data = Papa.parse(text)
    parse_responses(data)


parse_review = (members_data, review_data) ->
    read_responses(review_data)


module.exports =
    parse: parse_review
