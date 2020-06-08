import $ from 'jquery';
window.$ = window.jQuery = require('jquery');

$(document).ready(function(){
    $("#metadata_agid").on('click', function () { 
        return confirm("Confermi l'invio dei metadata ad Agid?"); 
    }); 

})


