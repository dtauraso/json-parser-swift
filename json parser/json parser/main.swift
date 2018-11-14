// from original file
//
//  JSON.swift
//  TaskTimeCalendar-swift
//
//  Created by David on 11/7/16.
//  Copyright © 2016 David. All rights reserved.
//

import Foundation


/*
doing this reguardless of the kind of content I will be storing via json
tests for json object
    replace string tests, value tests with the tests for those specifit items = *
    {}
    {*}
    {*: *}
    {* : *}
    {*:*}
    {* :*}
    {* : *}
    {* : *}
    {* : *}
 
 
 
tests for json string (for string literals)
    "\" ref id\""
    ""
    "\"\""
    "\"\\\\\""
    "\"jhtres\""
    "\"uytrewytre345678\""
    "\"876543\""
 
    all pass
 
 
tests for json number
    2
    3
    5432
    gfhd    (should fail)
    0
    g       (should fail)
    ""      (should fail)
start small and build up
*/

class Timer
{
    var hours : Int = Int()
    var minutes : Int = Int()
    init(){}
}
class Item
{
    var id : Int = Int()
    var title : String = String()
    var note : String = String()
    var tags : [String] = [String]()
    var timer : Timer = Timer()
    var is_task : Bool = Bool()
    var is_note : Bool = Bool()
    var is_event : Bool = Bool()
    init(){}
    
    func Print()
    {
        print(id)
        print(title)
        print(note)
        print(tags)
        print(timer)
        print(is_task)
        print(is_note)
        print(is_event)
        
    }
}
//// MARK: JSON parser
class JSONParser
{

    /*
    object --> {string:value[,string:value]}

    array  --> [value[,value]]

    value  --> string | number | object | array
    
    string --> string
    
    number --> number
    
    true   --> true
    
    false  --> false
    
    null   --> null
    getArray -> [value]
    
    getObject -> [String: value]
    
    getVaue -> value
    
    
    pull a character out
        if it signifies something and is included in the something's definition
            add character back into stream
    
    */
    var stream = [Character]()
    init(stream_in: String)
    {
        // convert from String to [Character]
        for character in stream_in.characters
        {
            stream.append(character)
        }
    }
    
    init() {}

    func printStates(state: Int, function_name: String)
    {
        /*let start = 0;
        let lparen = 1;
        let rparen = 2;
        let string = 3;
        let colon = 4;
        let value = 5
        let whitespace = 6
        */
        if state == 0
        {
            if function_name == "jsonString"
            {
                print("start")
            }
            else if function_name == "jsonObject"
            {
                print("start")
            }
            //print("start")
        }
        else if state == 1
        {
            if function_name == "jsonString"
            {
                 print("start_quote")
            }
            else if function_name == "jsonObject"
            {
                print("lparen")
            }
            //print("start_back_slash")
        }
        else if state == 2
        {
            if function_name == "jsonString"
            {
                print("end_quote")
            }
            else if function_name == "jsonObject"
            {
                print("rparen")
            }
            //print("keep_going")
        }
        else if state == 3
        {
            if function_name == "jsonString"
            {
                print("char")
            }
            else if function_name == "jsonObject"
            {
                print("string")
            }
            //print("backup")
        }
        else if state == 4
        {
            if function_name == "jsonString"
            {
                print("back_slash")
            }
            else if function_name == "jsonObject"
            {
                print("colon")
            }
            //print("end_back_slash")
        }
        else if state == 5
        {
            if function_name == "jsonString"
            {
                print("intermediate_quote_back_slash")
            }
            else if function_name == "jsonObject"
            {
            }
           // print("intermediate_quote_back_slash")
        }
            }
    
    
    
    func isValue(char: Character) -> Bool
    {
        return char == "\""             ||
               isNumber(digit: char)    ||
               char == "{"              ||
               char == "["              ||
               char == "t"              ||
               char == "f"              ||
               char == "n"
    }
    
    func jsonArray(json_string: inout [Character]) -> [Any?]  // value may be nill
    {
        // states
        let start = 0
        let lbracket = 1
        let rbracket = 2
        let value = 3
        let whitespace_1 = 4
        let comma = 5
        let whitespace_2 = 6
        
        let error = -1
        let state_transition_graph : [Int: [String: Int]] =
        
        [
            start : ["[" : lbracket],
            lbracket : ["whitespace" : lbracket, "]" : rbracket, "value" : value],
            value : ["]" : rbracket, "whitespace" : whitespace_1, "," : comma],
            whitespace_1 : ["]" : rbracket, "whitespace" : whitespace_1, "," : comma],
            comma : ["value" : value, "whitespace" : whitespace_2],
            whitespace_2 : ["whitespace" : whitespace_2, "value" : value]
        
        
        ]
        
        var state = 0
        var array : [Any?] = []
        var i = 0
        while true
        {
            assert(50 != i, "i is out of bounds i = " + String(i))
            //print(json_string)
            //print()
            var state_changed = false
            for a_string in (state_transition_graph[state]?.keys)!
            {
                if (a_string == String(json_string[0])                                  ||
                   (a_string == "value" && isValue(char: json_string[0]))               ||
                   (a_string == "whitespace" && isWhiteSpace(digit: json_string[0])))
                   {
                        state = (state_transition_graph[state]?[a_string])!
                        state_changed = true
                   }
            }
            
            if !state_changed
            {       state = -1   }
            
            // state actions
            if state == lbracket     ||
               state == whitespace_1 ||
               state == comma        ||
               state == whitespace_2
            {
                json_string = [Character](json_string.dropFirst())
            }
            else if state == rbracket
            {
                json_string = [Character](json_string.dropFirst())
                return array
            }
            else if state == value
            {
                array.append(jsonValue(json_string: &json_string))
            }
            
            assert(state != error, "error state")
           // print(json_string)
            i += 1
        }
        
    }
    
    func isNumber(digit: Character) -> Bool
    {
    
        return digit >= "0" && digit <= "9"
    }

    func isWhiteSpace(digit: Character) -> Bool
    {
        return digit == " "     ||
               digit == "\n"    ||
               digit == "\t"    ||
               digit == "\r"
    }

    func jsonObject(json_string: inout [Character]) -> [String: Any?]  // value may be nil
    {
        // states
        let start = 0;
        let lparen = 1;
        let rparen = 2;
        
        let string = 3;
        let whitespace_1 = 4;
        let colon = 5;
        let whitespace_2 = 6;
        let value = 7;
        let whitespace_3 = 8;
        let comma = 9;
        let whitespace_4 = 10
        
        let error = -1
        // rparen is an end state so it is not included in state_transition_graph
        let state_transition_graph : [Int : [String: Int]] =
        [
            start : ["{" : lparen],
            lparen : ["whitespace" : lparen, "}" : rparen, "\"" : string],
            
            string : ["whitespace" : whitespace_1, ":" : colon],
            whitespace_1 : ["whitespace" : whitespace_1, ":" : colon],

            colon : ["whitespace" : whitespace_2, "value" : value],
            whitespace_2 : ["whitespace" : whitespace_2, "value" : value],
            
            value : ["}" : rparen, "whitespace" : whitespace_3, "," : comma],
            whitespace_3 : ["}" : rparen, "whitespace" : whitespace_3, "," : comma],

            comma : ["whitespace" : whitespace_4, "\"" : string],
            whitespace_4 : ["whitespace" : whitespace_4, "\"" : string]
        
        ]
        var state = 0
        var i = 0
        var object = [String: Any]()
        // the dict entry has to be set in one statement
        // key is collected in a different state than _value(below)
        var key = String()
        
        while true
        {
            assert(i != 70, "loop_count is too far loop_count = " + String(i))
            
            
            //print(json_string)
            //print()
            // state transition conditions

            var state_changed = false
            // parenthesis adds(or exposes) optional type part to the end of the non optional type?
            for a_char in (state_transition_graph[state]?.keys)!  // no idea what these mean in the expression(), ?, and !
            {
                if (a_char == String(json_string[0]))                               ||
                   (a_char == "whitespace" && isWhiteSpace(digit: json_string[0]))  ||
                   (a_char == "value" && isValue(char: json_string[0]))
                {
                    state = (state_transition_graph[state]?[a_char])!
                    state_changed = true
                }

            }
            
            if !state_changed
            { state = -1          }
            
            // state actions
            if state == lparen       ||
               state == whitespace_1 ||
               state == colon        ||
               state == whitespace_2 ||
               state == whitespace_3 ||
               state == comma        ||
               state == whitespace_4
            {
                json_string = [Character](json_string.dropFirst())
            }
            else if state == rparen
            {
                json_string = [Character](json_string.dropFirst())
                break
            }
            
            else if state == string
            {
                // goes here even if there is a whitespace
                // resets key if there is more than 1 key value pair
                key = jsonString(json_string: &json_string)
                
            }
            else if state == value
            {
                let _value = jsonValue(json_string: &json_string)
                object[key] = _value
                
            }
            // after it got the string it went into the error state
            assert(state != error, "error state")
            

            i += 1
        
        }
        return object

    }
    
    func jsonValue(json_string: inout [Character]) -> Any?   // ? for nil
    {
        if json_string.isEmpty
        {   return "can't collect characters" }
        
        else if json_string[0] == "\""
        {
            // string
            return jsonString(json_string: &json_string)
        }
        else if isNumber(digit: json_string[0])
        {
            // number
            return jsonNumber(json_string: &json_string)
        }
        else if json_string[0] == "{"
        {
            // object
            return jsonObject(json_string: &json_string)
        }
        else if json_string[0] == "["
        {
            // array
            return jsonArray(json_string: &json_string)
        }
        else if json_string[0] == "t"
        {
            // true
            assert(json_string.count >= 4, "string is not large enought for true")

            if (json_string[1] == "r" &&
                json_string[2] == "u" &&
                json_string[3] == "e")

            {
                // erase "true" from json_string
                
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                return true
            }
        }
        else if json_string[0] == "f"
        {
            // false
            assert(json_string.count >= 5, "string is not large enought for false")
            if (json_string[1] == "a" &&
                json_string[2] == "l" &&
                json_string[3] == "s" &&
                json_string[4] == "e")

            {
            
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                return false
                
            }
        }
        else if json_string[0] == "n"
        {
            assert(json_string.count >= 4, "string is not large enought for null")
            if (json_string[1] == "u" &&
                json_string[2] == "l" &&
                json_string[3] == "l")

            {
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                json_string = [Character](json_string.dropFirst())
                return nil
                
            }

        }
        
        
        return 0
    }

    func charNotQuoteNotBackslash(char: Character) -> Bool
    {
        return char != "\"" && char != "\\"
    }
    
    func jsonString(json_string: inout [Character]) -> String
    {
        /*
        {state_no -> {current_char, next_state} -> {current_char, next_state}}
        
        
        */
        //print(json_string)
        if json_string.isEmpty
        {   return "can't collect characters" }
        
        // initial state
        let start = 0;
        
        // intermidiate state
        let start_quote = 1;
        let char = 3
        let back_slash = 4
        let intermediate_quote_back_slash = 5
        
        // final state
        let end_quote = 2
        
        // error
        let error = -1
        var string = String()
        // end_quote should not be a key
        let state_transition_dict : [Int: [String: Int]] =
        [
            start : ["\"" : start_quote],
            start_quote : ["\"" : end_quote/* null string */, "charNotQuoteNotBackslash" : char, "\\" : back_slash],
            char : ["charNotQuoteNotBackslash" : char, "\\" : back_slash, "\"" : end_quote],
            back_slash : ["\"" : intermediate_quote_back_slash, "\\" : intermediate_quote_back_slash],
            intermediate_quote_back_slash : ["\"" : end_quote, "charNotQuoteNotBackslash" : char, "\\" : back_slash],
            
        ]
        
        var loop_count = 0
        var state = 0
        while true
        {
        
            // assert loop too far
            assert(loop_count != 70, "loop_count is too far loop_count = " + String(loop_count))
            //print("i = " + String(i))
            //print("current char")
            //print(json_string[0])
            //print("state")
            //printStates(state: state, function_name: "jsonString")
            //print("->")

            var state_changed = false
            // transition conditions
            for char in (state_transition_dict[state]?.keys)!
            {
            
                // must check for function name separately because function name is not in input
                if (char == String(json_string[0])) ||
                   (char == "charNotQuoteNotBackslash" && charNotQuoteNotBackslash(char: json_string[0]))
                {
                    state = (state_transition_dict[state]?[char])!
                    state_changed = true
                    //printStates(state: state, function_name: "jsonString")
                    //print("------")
                }

            }
            // if there is no item in dict then state must be set to -1
            if !state_changed
            {    state = -1     }

            // state actions
            if state == start_quote  // why here at ] before cycle?
            {
                json_string = [Character](json_string.dropFirst())
            }
            else if state == char                           ||
                    state == back_slash                     ||
                    state == intermediate_quote_back_slash
            {
                string = string + String(json_string[0])
                json_string = [Character](json_string.dropFirst())
                
                //print(json_string)

            }
            
            else if state == end_quote
            {
                json_string = [Character](json_string.dropFirst())
                break
             }
            
            // error state assert
            assert(state != error, "error state")
            loop_count += 1
        }

        return string
    }
    
    
    func jsonNumber(json_string: inout [Character]) -> Int
    {


        //print("number")
        //print(json_string)
        if json_string.isEmpty
        {   return -1 }

        //print(json_string[0] >= "0" && json_string[0] <= "9")
        assert(json_string[0] >= "0" && json_string[0] <= "9", "character at current_index != digit")
        

        //var i = 0
        var number = 0
        while (!json_string.isEmpty && isNumber(digit: json_string[0]))
        {
            let digit = Int(String(json_string[0]))
            number *= 10
            number += digit!

            json_string = [Character](json_string.dropFirst())
            //print(json_string)

        }
        return number
    }
}

func createItem(task: Any) -> Item
{
    // can't mutate things that have to be typecasted so they have to be copied to an object that can be mutated
    // copy data out using double typecasting

    let item: Item = Item()
    item.id = (task as! [String: Any?])["id"] as! Int
    item.title = (task as! [String: Any?])["title"] as! String
    item.note = (task as! [String: Any?])["note"] as! String
    item.tags = (task as! [String: Any?])["tags"] as! [String]
    item.timer.hours = (((task as! [String: Any?])["timer"] as! [String: Int])["hours"] )!
    item.timer.minutes = (((task as! [String: Any?])["timer"] as! [String: Int])["minutes"] )!
    item.is_task = (task as! [String: Any?])["is_task"] as! Bool
    item.is_note = (task as! [String: Any?])["is_note"] as! Bool
    item.is_event = (task as! [String: Any?])["is_event"] as! Bool

    return item
}
func printStuff()
{
    var items_from_file : [Any] = []
    let t_c_n_collection = ["[{\"id\" : 0 ,\"title\" : \"     test\", \"note\" : \"this is a note\", \"tags\" : [\"tag one\", \"tag two\"], \"timer\" : {\"hours\" : 23, \"minutes\" : 09}, \"is_task\" : true, \"is_note\": false, \"is_event\" : false}, {\"id\" : 1 ,\"title\" : \"     Talk to A or b about\", \"note\" : \"this is another note\", \"tags\" : [\"tag three\", \"tag four\"],\"timer\" : {\"hours\" : 03, \"minutes\" : 50}, \"is_task\" : true, \"is_note\" : false, \"is_event\" : false}, {\"id\" : 2, \"title\" : \"     title3dfghjkjhgfdfghjkfdfghjkkfdfghklgfghjklkgfghjkjhgfgh\", \"note\": \"\", \"tags\" : [], \"timer\" : {\"hours\" : 0, \"minutes\" : 0}, \"is_note\" : true, \"is_task\" : false, \"is_event\" : false}, {\"id\" : 3, \"title\" : \"     title5\", \"note\": \"\", \"tags\" : [], \"timer\" : {\"hours\" : 0, \"minutes\" : 0}, \"is_task\" : false, \"is_note\" : false,\"is_event\" : true}]"]

    // timer_hours_string
    // timer_minutes_string
    // what am I doing to do with the timer?
    // after a minutes has gone by
    // seubtract 1 minute from all timers that are active
    for element in t_c_n_collection
    {
        var array_of_chars = [Character]()
        
        for char in element.characters
        {
            array_of_chars.append(char)
        }
        //print(array_of_chars)
        let json_parser : JSONParser = JSONParser()
        items_from_file = json_parser.jsonArray(json_string: &array_of_chars)
        
        /*for item in items_from_file
        {
            print(item)
            print()
        }*/
       var items = items_from_file.map({createItem(task: $0)})

        items.map({$0.Print()})
        //setTask(task: tasks[0])
        
    }

}

printStuff()
