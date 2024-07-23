(function() {
  var Parser, SearchQueryParser;

  Parser = require('./basic_parser');

  SearchQueryParser = (function() {
    var operator, pad, token, _ref;

    function SearchQueryParser() {}

    SearchQueryParser.TOKEN_TO_OPERATOR = {
      less_than: '<',
      less_than_or_equals: '<=',
      greater_than: '>',
      greater_than_or_equals: '>=',
      equals: '',
      not_equals: ''
    };

    SearchQueryParser.OPERATOR_TO_TOKEN = {};

    _ref = SearchQueryParser.TOKEN_TO_OPERATOR;
    for (token in _ref) {
      operator = _ref[token];
      SearchQueryParser.OPERATOR_TO_TOKEN[operator] = token;
    }

    SearchQueryParser.NOT_TOKEN = {
      greater_than: 'less_than',
      less_than: 'greater_than',
      equals: 'not_equals',
      not_equals: 'equals',
      greater_than_or_equals: 'less_than_or_equals',
      less_than_or_equals: 'greater_than_or_equals'
    };

    SearchQueryParser.tokenize = function(input) {
      var key, positiveMatch, results, tree, word,
        _this = this;
      tree = Parser.parse(input);
      results = [];
      word = positiveMatch = key = operator = void 0;
      if (tree.children.length < 1) {
        throw new Error("Couldn't parse search query!");
      }
      tree.traverse({
        traversesTextNodes: false,
        enteredNode: function(node) {
          var innerText;
          if (node.error) {
            throw new Error(node.message());
          }
          switch (node.name) {
            case "Definition":
              positiveMatch = true;
              key = 'default';
              operator = 'equals';
              return true;
            case "MatchMode":
              positiveMatch = node.innerText() === '+';
              return true;
            case "Integer":
              word = parseInt(node.innerText(), 10);
              return false;
            case "Float":
              word = parseFloat(node.innerText());
              return false;
            case "Date":
              innerText = node.innerText().split('-').map(function(val) {
                return parseInt(val, 10);
              });
              word = new Date(innerText[0], innerText[1] - 1, innerText[2]);
              word = new Date(word - word.getTimezoneOffset() * 1000 * 60);
              return false;
            case "String":
              if (node.children[0].name === 'BareWord') {
                word = node.innerText();
              } else {
                word = node.innerText().slice(1, -1);
                word = word.trim();
              }
              return false;
            case "Operator":
              operator = _this.OPERATOR_TO_TOKEN[node.innerText()];
              return false;
            default:
              return true;
          }
        },
        exitedNode: function(node) {
          switch (node.name) {
            case "Pair":
              return key = node.children[0].innerText();
            case "Definition":
              if (!positiveMatch) {
                operator = _this.NOT_TOKEN[operator];
              }
              return results.push([key, operator, word]);
          }
        }
      });
      return results;
    };

    SearchQueryParser.build = function(tokens) {
      var component, key, results, value;
      results = (function() {
        var _i, _len, _ref1, _results;
        _results = [];
        for (_i = 0, _len = tokens.length; _i < _len; _i++) {
          _ref1 = tokens[_i], key = _ref1[0], operator = _ref1[1], value = _ref1[2];
          component = "" + this.TOKEN_TO_OPERATOR[operator] + (this.format(value));
          if (key !== 'default') {
            component = "" + key + ":" + component;
          }
          if (operator === 'not_equals') {
            component = "-" + component;
          }
          _results.push(component);
        }
        return _results;
      }).call(this);
      return results.join(' ');
    };

    pad = function(val) {
      val = "" + val;
      if (val.length === 1) {
        val = "0" + val;
      }
      return val;
    };

    SearchQueryParser.format = function(value) {
      var coreValue, endChar, startChar;
      if (value instanceof Date) {
        return "" + (value.getUTCFullYear()) + "-" + (pad(value.getUTCMonth() + 1)) + "-" + (pad(value.getUTCDate()));
      }
      if ((value.indexOf != null) && value.indexOf(' ') !== -1) {
        startChar = value.slice(0, 1);
        endChar = value.slice(-1);
        if (startChar === endChar && (startChar === '"' || startChar === "'")) {
          coreValue = value.slice(1, -1);
          return startChar + coreValue.replace(/#{startChar}/, "\\" + startChar) + startChar;
        } else {
          return '"' + value.replace(/"/g, '\"') + '"';
        }
      } else {
        return value;
      }
    };

    return SearchQueryParser;

  })();

  module.exports = SearchQueryParser;

}).call(this);
