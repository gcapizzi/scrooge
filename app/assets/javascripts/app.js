//= require foundation

window.App = Ember.Application.create();

App.Account = Ember.Object.extend({});

App.Account.reopenClass({
  findAll: function() {
    return $.getJSON('/accounts').then(function(response) {
      return response.accounts.map(function(account) {
        return App.Account.create(account.account);
      });
    });
  }
});

App.IndexRoute = Ember.Route.extend({
  model: function() {
    return App.Account.findAll();
  }
});
