require('coffee-script/register')

var express = require('express');
var app = express();
var http    = require('http').Server(app);
var path    = require('path');
var session = require('express-session');
var bparser = require('body-parser');

var loadData = require('./src/ReadData');
var review_parser = require('./src/review_parser');
var data_manager = require('./src/datamanager');

var fs = require('fs')

// Configure app
app.use(express.static(path.join(__dirname, 'public')));
app.use(bparser.urlencoded({ extended: false }))
app.use(bparser.json());
app.set("view engine", "jade");
//app.use(cparser());
app.use(session({secret:'dwsecretbackend'}));

responses = {}
reviews = {}

app.get('/', function(req, res) {
    res.render("index", {
        review_list: dm.reviews,
        notice: ""
    });
});

app.post('/load_from', function(req, res) {

    if (!dm.review_exists(req.body.url))
    {
        dm.add_new_review(req.body.url, req.body.members_list_url,function (review) {
            res.redirect("/");
        });
    }
    else
    {
        res.render("index", {
            review_list: dm.reviews,
            notice: "This review already exists"
        });
    }
});

app.get('/review/*', function(req, res) {
    var review = req.params[0];
    if (dm.contains_by_date(review))
    {
        responses = dm.get_review_by_date(review).review;
        res.redirect("/members");
    }
    else
        res.render("404");
});

app.get('/members', function(req, res) {

    res.render("members", {
        members: responses.members
    });
    //res.sendFile(__dirname + '/members.html');
});

app.get('/review_feedback', function(req, res) {

    res.render("review_feedback", {
        reviewers: responses
    });
    //res.sendFile(__dirname + '/members.html');
});

function members_resp(req, res, name, st_id)
{
    //var members = Object.keys(responses);
    var members = responses.members;
    var index = members.indexOf(name);

    if (index != -1)
    {
        var previous = members[index-1];
        var next = members[index+1];

        var review = responses.responses[name];
        var data = review_parser.get_chart_data(review);
        var reviewers_by_user = review_parser.get_reviewers_for(responses.responses, members[index]);
        var g_feedback = review_parser.get_general_feedback(reviewers_by_user);

        res.render(st_id > 0 ? "review_table" : "member", {
            user_name: members[index],
            reviewers: reviewers_by_user,
            review: review, // User's evaluation
            data: data,     // Chart data
            general_feedback: g_feedback,
            statement_idx: st_id,
            statements: review_parser.statements(),
            statements_text: review_parser.statements_text(),
            short_interactions: review_parser.short_interactions(),
            previous_member: previous,
            next_member: next
        });
    }
    else
    {
        res.send("There is not such member");
    }
}

app.get('/members/:name', function(req, res) {
    members_resp(req, res, req.params.name, 0);
});

app.get('/members/:name/:id', function(req, res) {
    members_resp(req, res, req.params.name, req.params.id);
});

app.get('/chart', function(req, res) {
    res.sendFile(__dirname + '/chart.html');
});

var dm = new data_manager.DataManager();
dm.initialize();
dm.load_reviews();


http.listen(7777, function(){
    console.log('Listening on *:7777');
});
