Papa = require 'papaparse'
Array::contains = (value) -> this.indexOf(value) != -1

slice_marker = "Want to save and continue later? - click below"
members = []

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


interaction_freq = [
    "Daily",
    "Worked alongside each other on big project(s) or had regular interaction",
    "Occasionally",
    "On a few occasions and can give some feedback",
    "Insufficient interactions / will not review",
    "Self Evaluated"
]

Insufficient_inter_id = 4 # workaround
get_interactions = ->
    interaction_freq.filter (item) ->
        item != interaction_freq[Insufficient_inter_id]

get_statements = ->
    Object.keys(column_name_map)[2..]

get_separators_indicies = (headers, separator) ->
    (idx for value, idx in headers when value == separator)

split_array = (array, split_indexes) ->
    slices = []
    begin = 0

    slices = for sep_idx in split_indexes
        sl = array.slice begin, sep_idx
        begin = sep_idx + 1
        sl
    slices


check_my_name = (name) ->
    if members.contains name
        name
    else
        name = name.split(' ').reverse().join(' ')
        name if members.contains name


swap_columns = (data, indicies) ->
    for _, i in data.data
        d = data.data[i]
        for index in indicies
            do(index) ->
                a = d[index-1]
                d[index-1] = d[index]
                d[index] = a



remove_redudant_columns = (data, indicies) ->
    # remove indicies placed at odd positions in this array.
    #indicies = indicies.filter (item, index) -> (index % 2 != 0)
    for _, i in data.data
        data.data[i] = data.data[i].filter (item, index) ->
            indicies.indexOf(index) == -1


read_self_evaluation = (data) ->
    obj = {}
    idx = 0

    # Read all the rest fields
    for key, answer of column_name_map
        if answer.has_comment
            obj[key] = {
                score: data[idx++],
                comment: data[idx++]
            }
        else
            obj[key] = data[idx++]
    obj


read_evaluation = (fields, data) ->
    obj = {}
    idx = 0

    # Read all the rest fields
    for key, field of fields
        if field.has_comment
            obj[key] = {
                score: Number(data[idx++]),
                comment: data[idx++]
            }
        else
            obj[key] = data[idx++]
    obj


parse_responses = (data) ->
    #global variable
    response_split_indicies = get_separators_indicies(data.data[0], slice_marker)
    #Skip first 3 
    remove_redudant_columns(data, response_split_indicies.slice(2,3))
    # Get new split indicies.
    response_split_indicies = get_separators_indicies(data.data[0], slice_marker)
    swap_columns(data, response_split_indicies.slice(2))
    response_split_indicies = get_separators_indicies(data.data[0], slice_marker)


    results = {}

    for resp_data, idx in data.data[1..]
        responses = split_array(resp_data, response_split_indicies)

        result = {}
        result.self  = read_evaluation(column_name_map, responses[0])
        result.self.statements = {}
        for statement in Object.keys(column_name_map)[2..]
            result.self.statements[statement] = result.self[statement]
            delete result.self[statement]

        result.bully = read_evaluation(bully_columns, responses[1])
        my_name = check_my_name result.self.your_name

        if not my_name?
            console.log "Error: the name is invalid"

        #console.log "My name is #{my_name}"

        answer_id = 2
        for member in members
            break if member == ""
            if member != my_name
                #console.log "Read about #{member}, response #{responses[answer_id]}"
                result[member] = read_evaluation(member_columns, responses[answer_id++])

        results[my_name] = result

    results


parse_members = (text) ->
    text = text.replace /,/g, ' '
    array = text.split '\r\n'


substitute_headers = (text) ->
    for key, value of column_name_map
        text = text.replace(new RegExp(value.text, 'g'), key)
    text


calc_scores = (target_name, target, all_responses) ->
    target.scores = {}

    for statement, response of target.self.statements
        if not target.scores[statement]?
            target.scores[statement] = []

        if response.score isnt 0
            target.scores[statement].push {
                score: response.score,
                interaction_freq: "Self Evaluated"
            }

    #console.log all_responses["Dmitrii Emeliov"][target_name]
    for member_name, responser of all_responses
        continue if member_name == target_name
        target_eval = responser[target_name]
        continue if target_eval.interaction_freq == interaction_freq[Insufficient_inter_id]

        for statement, response of target_eval
            continue if typeof response isnt "object"

            if not target.scores[statement]?
                target.scores[statement] = []

            if response.score isnt 0
                target.scores[statement].push {
                    score: response.score,
                    interaction_freq: target_eval.interaction_freq
                }

class Data
    constructor: (name, data) -> 
        @type = "stackedColumn"
        @toolTipContent = ""
        @name = name #interaction_freq
        @showInLegend = "true"
        @dataPoints = data

class ChartData
    constructor: (results) ->
        @title = { text: "" }
        @axisY = {title: "Number of ..."}
        @animationEnabled = true
        data = []
        #console.log results

        @data = for inter_freq in interaction_freq
            continue if inter_freq == interaction_freq[Insufficient_inter_id]

            result = for k, v of results
                ammount = v.length
                # group score by interaction frequency
                score_by_inter = v.filter (item) -> item.interaction_freq == inter_freq
                { y: score_by_inter.length/ammount, label: k }

            new Data inter_freq, result

        @legend = {}


# Returns data for chart for evaluation
get_chart_data = (evaluation) ->
    chartDatas = {}
    for statement in Object.keys(column_name_map)[2..]
        chartDatas[statement] = new ChartData evaluation.results[statement]
    chartDatas

calc_analitics = (resp) ->

    for target_name, value of resp
        # Go through members responses and collect all scores
        # in respounse.scores array.
        #respounse.scores = { question_1: [ {score: x, interaction_freq: y}, ...],
        #                     question_2: [ {score: x, interaction_freq: y}, ...], ...
        #                   }
        calc_scores(target_name, value, resp)

        #go through array value.scores 
        results = {}
        for statement, question_scores of value.scores
            #collect scores by value, group by interaction_freq
            res_by_statement = results[statement] = {}

            for idx in [1..5]
                res_by_statement[idx] = question_scores.filter (item, index) ->
                    item.score == idx

        value.results = results


read_responses = (text) ->
    text = substitute_headers(text)
    data = Papa.parse(text)
    responses = parse_responses(data)
    calc_analitics(responses)
    #get_chart_data responses["Dmitrii Emeliov"]
    responses


parse_review = (members_data, review_data) ->
    members = parse_members(members_data)
    read_responses(review_data)


module.exports =
    parse: parse_review
    get_chart_data: get_chart_data
    interactions: get_interactions
    statements: get_statements
