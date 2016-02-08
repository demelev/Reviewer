function update_chart(index)
{
    var chart = new CanvasJS.Chart('chartContainer', chartData[statements[index]]);
    chart.render();
}

function update_form(index)
{
    var statement = document.getElementById("statement");
    statement.innerHTML = statements_text[statements[index]];

    var average = document.getElementById("average");
    average.innerHTML = "Average Score: " + average_score[statements[index]];

    update_chart(index);
}
