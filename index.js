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
        dm.add_new_review(req.body.url, req.body.members_list_url, (review) => {
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
        members: Object.keys(responses)
    });
    //res.sendFile(__dirname + '/members.html');
});

app.get('/members/*', function(req, res) {
    var members = Object.keys(responses);
    var index = members.indexOf(req.params[0]);

    if (index != -1)
    {
        var previous = members[index-1];
        var next = members[index+1];
        console.log("prev: " + previous);
        console.log("next: " + next);

        var review = responses[req.params[0]];
        var data = review_parser.get_chart_data(review);
        //res.send(JSON.stringify(data['perform_tasks']));

        console.log('statements text : ' + review_parser.statements_text());
        res.render("member", {
            review: review,
            data: data,
            statements: review_parser.statements(),
            statements_text: review_parser.statements_text(),
            previous_member: previous,
            next_member: next
        });
    }
    else
    {
        res.send("There is not such member");
    }
    //var chart = new CanvasJS.Chart("chartContainer", get_chart_data());
    //chart.render();
});

app.get('/chart', function(req, res) {
    res.sendFile(__dirname + '/chart.html');
});

/*
 *var members_data = fs.readFileSync(__dirname + '/public/members.csv', 'utf8');
 *var review_data = fs.readFileSync(__dirname + '/public/data.csv', 'utf8');
 *responses = review_parser.parse(members_data, review_data);
 */
var dm = new data_manager.DataManager();
dm.initialize();
dm.load_reviews();

//console.log(responses);

http.listen(8888, function(){
    console.log('Listening on *:8888');
});
