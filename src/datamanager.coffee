fs = require 'fs'
https = require 'https'
review_parser = require './review_parser'
read_data = require './ReadData'

class DataManager

    constructor: ->
        @on_add_new = null
        @review_list_info = {}

    initialize: ->
        console.log "DataManager: Initialization"
        this.load_review_list_info()


    add_new_review: (data_url, members_url, callback) ->
        obj = this

        read_data.load_data data_url, (data) ->
            read_data.load_data members_url, (members_data) ->

                review = {
                    date: new Date().toISOString(),
                    review: review_parser.parse(members_data, data)
                }

                obj.add_review(data_url, review)

                if @on_add_new?
                    @on_add_new(review)

                callback? review


    load_reviews: ->
        @reviews = for _, review_info of @review_list_info
            data = fs.readFileSync review_info.path
            JSON.parse data

        @reviews = [] if not @reviews?

    make_file_name: (url) ->
        re = /^.*\/d\/(.*?)\/.*$/
        match = re.exec(url)
        "data/Review - #{match[1]}.json"

    add_review: (url, review) ->
        review_path = this.make_file_name url
        #console.log @review_list_info

        @review_list_info[url] = {
            path: review_path
        }

        @reviews.push review

        this.save_review review, review_path
        this.save_review_info()
        

    save_review: (review, path) ->
        fs.writeFileSync path, JSON.stringify review

    save_review_info: ->
        fs.writeFileSync "data/list_info.json", JSON.stringify @review_list_info

    get_review_by_date: (date) ->
        for review in @reviews
            return review if review.date == date
        null

    contains_by_date: (date) ->
        for review in @reviews
            return true if review.date == date
        false

    review_exists: (url) ->
        @review_list_info[url]?
            
    load_review_list_info: ->
        path = "data/list_info.json"
        try
            review_list_data = fs.readFileSync path, "utf-8"
            @review_list_info = JSON.parse(review_list_data)
        catch error
            if error.code == 'ENOENT'
                @review_list_info = {}
                console.log "List info error" + @review_list_info
                this.save_review_info()

module.exports =
    DataManager: DataManager
