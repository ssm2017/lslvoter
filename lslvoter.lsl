// @version lslvoter
// @package lslvoter
// @copyright Copyright wene / ssm2017 Binder (C) 2014. All rights reserved.
// @license http://www.gnu.org/licenses/gpl-2.0.html GNU/GPL, see LICENSE.php
// lslvoter is free software and parts of it may contain or be derived from the
// GNU General Public License or other free or open source software licenses.

// #######################
//     STRINGS
// #######################
string _YES = "Yes";
string _NO = "No";
string _ABST = "Abstention";
string _NOT_DEFINED = "Not defined";
string _HAS_VOTED = "has voted.";
string _HAS_VOTED_AGAIN = "has voted again.";
string _NOT_ALLOWED = "You are not allowed to vote.";
string _NOTECARD_READ = "We are done reading the notecard";
string _MISSING_NOTECARD = "Missing inventory notecard";
string _READING_NOTECARD = "Reading notecard";
string _INITIALISATION = "Initialisation";
string _NAME_DEFINED_TO = "Name defined to";
string _PRESENTS = "Presents";
string _ABSENTS = "Absents";
string _VOTES = "Votes";
string _NO_VOTE_YET = "No vote yet";
string _NO_VOTES = "No votes";
string _NON_VOTED = "Non voted";
string _RESULTS = "Results";
string _VOTE_READY = "Vote ready";
string _READY_TO_VOTE = "Ready to vote";
string _VOTING = "Voting";
string _STOP = "Stop";
string _WRONG_VOTE_VALUE = "Wrong vote value";
// infos
string _DISPLAYING_INFOS = "Displaying infos";
string _INFOS = "Infos";
string _MY_INFOS = "My infos";
string _MY_KEY_IS = "My key is";
string _MY_NAME_IS = "My name is";
string _MY_CODE_IS = "My code is";
string _MY_VOTE_IS = "My vote is";
// help
string _HELP = "Help";
string _HELP_HELP = "Displays this help message";
string _HELP_MY = "Displays my personnal infos (uuid, name, code, vote)";
string _HELP_VOTE = "Allows you to vote using the command line instead of touching the object (anybody can ear the vote with a script)";
string _HELP_RESET = "Resets the script (only for owner)";
string _HELP_STOP = "Stops the vote and displays results (only for owner)";
string _HELP_INFOS = "Displays the vote infos (who has not voted)(only for owner)";
string _HELP_NAME = "Change the name of the vote with <vote_name> value (only for owner)";

// listener channel
integer LISTEN_CHANNEL = 42;
// notecard name
string notecardName = "voters";

// ##########################################
// NOTHING SHOULD BE CHANGED UNDER THIS LINE
// ##########################################

// listener
integer listenHandler;

// users
list presents = [];
list absents = [];
list votes = [];
list votes_values = [];
key voter;
integer vote;
key owner;

// init
init()
{
    llSay(0, "\n==================\n    " + _INITIALISATION + "\n==================\n");
    votes_values = [_YES, _NO, _ABST];
    vote_name = _NOT_DEFINED;

    //  make sure the file exists and is a notecard
    if(llGetInventoryType(notecardName) != INVENTORY_NOTECARD)
    {
        //  notify owner of missing file
        llSay(0, _MISSING_NOTECARD + " : " + notecardName);
        //  don't do anything else
        return;
    }

    // change the prims colors and text
    llSetText(_READING_NOTECARD, <1.0, 1.0, 0.0>, 1.0);
    llSetColor(<1.0, 1.0, 0.0>, ALL_SIDES);
    llSetTexture(NULL_KEY, ALL_SIDES);

    llSetLinkPrimitiveParamsFast(2, [
    PRIM_TEXT, _YES, <1.0, 1.0, 0.0>, 1.0,
    PRIM_COLOR, ALL_SIDES, <0.0, 1.0, 0.0>, 1.0,
    PRIM_TEXTURE, ALL_SIDES, NULL_KEY, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
    PRIM_FULLBRIGHT, ALL_SIDES, 1]);

    llSetLinkPrimitiveParamsFast(3, [
    PRIM_TEXT, _NO, <1.0, 1.0, 0.0>, 1.0,
    PRIM_COLOR, ALL_SIDES, <1.0, 0.0, 0.0>, 1.0,
    PRIM_TEXTURE, ALL_SIDES, NULL_KEY, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
    PRIM_FULLBRIGHT, ALL_SIDES, 1]);

    llSetLinkPrimitiveParamsFast(4, [
    PRIM_TEXT, _ABST, <1.0, 1.0, 0.0>, 1.0,
    PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0,
    PRIM_TEXTURE, ALL_SIDES, NULL_KEY, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
    PRIM_FULLBRIGHT, ALL_SIDES, 1]);

    //  initialize to start reading from first line (which is 0)
    line = 0;
    notecardQueryId = llGetNotecardLine(notecardName, line);
}

// random code generator
string randomCodeGenerator(integer length)
{
    string CharSet = "abcdefghijkmnpqrstuvwxyz23456789";    // omitting confusable characters
    string password;
    integer CharSetLen = llStringLength(CharSet);
    // Note: We do _NOT add 1 to the length, because the range we want from llFrand() is 0 to length-1 inclusive

    while (length--)
    {
        integer rand = (integer) llFrand(CharSetLen);
        password += llGetSubString(CharSet, rand, rand);
    }
    return password;
}

// notecard
key notecardQueryId;
integer line;

readNotecard(string data)
{
    //  if we are at the end of the file
    if(data == EOF)
    {
        llSay(0, _NOTECARD_READ);
        displayInfos(1, 0);
    }

    //  if we are not working with a blank line
    if(data != "")
    {
        //  if the line does not begin with a comment
        if(llSubStringIndex(data, "#") != 0)
        {
            //  find first equal sign
            integer i = llSubStringIndex(data, "=");

            //  if line contains equal sign
            if(i != -1)
            {
                //  get name of name/value pair
                string name = llGetSubString(data, 0, i - 1);

                //  get value of name/value pair
                string value = llGetSubString(data, i + 1, -1);

                //  trim name
                name = llStringTrim(name, STRING_TRIM);

                //  trim value
                value = llStringTrim(value, STRING_TRIM);

                if (name != "" && value != "")
                {
                    sortAvatar(name, value);
                }
            }
        }
    }

    //  read the next line
    notecardQueryId = llGetNotecardLine(notecardName, ++line);
}


// vote
string vote_name = "";

recordVote()
{
    // check if voter is in presents list
    integer presents_index = llListFindList(presents, [voter]);
    if (presents_index != -1)
    {
        string voter_name = llList2String(presents, (presents_index + 1));
        string voter_code = llList2String(presents, (presents_index + 2));
        string vote_value = llList2String(votes_values, (vote - 2));

        // check if the user has already voted
        integer votes_index = llListFindList(votes, [voter_code]);
        if (votes_index != -1)
        {
            votes = llListReplaceList(votes, [vote_value], (votes_index + 1), (votes_index + 1));
            llSay(0, voter_name + " " + _HAS_VOTED_AGAIN);
        }
        else
        {
            votes = votes + [voter_code, vote_value];
            llSay(0, voter_name + " " + _HAS_VOTED);
        }
        displayMy(voter, 0);
    }
    else
    {
        llInstantMessage(voter, _NOT_ALLOWED);
    }
    state start;
}

sortAvatar(string name, key id)
{
    string realName = llKey2Name(id);
    if (realName != "")
    {
        presents = presents + [id, realName, randomCodeGenerator(4)];
    }
    else
    {
        absents = absents + [name];
    }
}

parseCommand(key id, string message)
{
    // parse command
    list parsed = llParseString2List( message, [ ":" ], [] );
    string command = llStringTrim(llToLower(llList2String( parsed, 0 )), STRING_TRIM);
    string value = llStringTrim(llList2String( parsed, 1 ), STRING_TRIM);

    if (id == owner) {
        if (command == "reset")
        {
            llResetScript();
        }
        else if (command == "name")
        {
            vote_name = value;
            llSay(0, _NAME_DEFINED_TO + " : " + vote_name);
        }
        else if (command == "infos")
        {
            state display_infos;
        }
        else if (command == "stop")
        {
            state stop;
        }
    }
    if (command == "help")
    {
        displayHelp(id);
    }
    else if (command == "my")
    {
        displayMy(id, 1);
    }
    else if (command == "vote")
    {
        // get the voter and value
        voter = id;
        // get the vote value
        integer votes_index = llListFindList(votes_values, [value]);
        if (votes_index != -1)
        {
            vote = votes_index + 2;
            state vote;
        }
        else
        {
            llInstantMessage(id, _WRONG_VOTE_VALUE);
        }

    }
}

displayHelp(key id)
{
    string help_text = "\n===================\n" + _HELP + "\n===================\n" +
                        "/" + LISTEN_CHANNEL + " help\n" +
                        _HELP_HELP + "\n" +
                        "------------------------\n" +
                        "/" + LISTEN_CHANNEL + " my\n" +
                        _HELP_MY + "\n" +
                        "------------------------\n" +
                        "/" + LISTEN_CHANNEL + " vote:<"+_YES+"/"+_NO+"/"+_ABST+">\n" +
                        _HELP_VOTE + "\n"+
                        "------------------------\n";
    if (id == owner)
    {
        help_text += "/" + LISTEN_CHANNEL + " reset\n" +
                    _HELP_RESET + "\n" +
                    "------------------------\n" +
                    "/" + LISTEN_CHANNEL + " stop\n" +
                    _HELP_STOP + "\n" +
                    "------------------------\n" +
                    "/" + LISTEN_CHANNEL + " infos\n" +
                    _HELP_INFOS + "\n" +
                    "------------------------\n" +
                    "/" + LISTEN_CHANNEL + " name:<vote_name>\n" +
                    _HELP_NAME + "\n" +
                    "------------------------\n";
    }
    llInstantMessage(id, help_text);
}

displayMy(key id, integer full)
{
    // get values
    integer presents_index = llListFindList(presents, [id]);
    if (presents_index != -1)
    {
        string my_key = (string)id;
        string my_name = llList2String(presents, (presents_index + 1));
        string my_code = llList2String(presents, (presents_index + 2));
        string my_vote = _NO_VOTE_YET;
        integer votes_index = llListFindList(votes, [my_code]);
        if (votes_index != -1)
        {
            my_vote = llList2String(votes, (votes_index + 1));
        }
        string text = "\n===================\n" + _MY_INFOS + "\n===================\n";
        if (full)
        {
            text += _MY_KEY_IS + " : " + my_key + "\n" +
                    _MY_NAME_IS + " : " + my_name + "\n";
        }
        text += _MY_CODE_IS + " : " + my_code + "\n" +
                _MY_VOTE_IS + " : " + my_vote + "\n" +
        "------------------------";
        llInstantMessage(id, text);
    }
    else
    {
        llInstantMessage(id, _NOT_ALLOWED);
    }
}

displayInfos(integer go_to_start, integer show_non_voted)
{
    string infos = "\n==========\n" + _INFOS + "\n==========\n";

    // show presents
    integer presents_count = 0;
    integer presents_length = llGetListLength(presents);
    infos += "--------------\n" + _PRESENTS + "\n--------------\n";
    integer i = 0;
    while(i < presents_length)
    {
        infos += llList2String(presents, (i+1)) + "\n";
        i = i + 3;
        presents_count++;
    }
    infos += _PRESENTS + " : (" + presents_count + ")\n";

    // show absents
    integer absents_count = 0;
    integer absents_length = llGetListLength(absents);
    infos += "--------------\n" + _ABSENTS + "\n--------------\n";
    i = 0;
    while(i < absents_length)
    {
        infos += llList2String(absents, i) + "\n";
        i = i + 1;
        absents_count++;
    }
    infos += _ABSENTS + " : (" + absents_count + ")\n";

    if (show_non_voted)
    {
        // show who has not voted
        integer non_voted_count = 0;
        infos += "--------------\n" + _NON_VOTED + "\n--------------\n";
        i = 0;
        while(i < presents_length)
        {
            // check if user has voted
            if (llListFindList(votes, [llList2String(presents, (i+2))]) == -1)
            {
                infos += llList2String(presents, (i+1)) + "\n";
                non_voted_count++;
            }
            i = i + 3;
        }
        infos += _NON_VOTED + " : (" + non_voted_count + ")\n";
    }

    // display the result
    llSay(0, infos);

    // return to vote
    if (go_to_start)
    {
        state start;
    }
}

displayResults()
{
    integer yes_votes = 0;
    integer no_votes = 0;
    integer abst_votes = 0;
    string text = "\n===============\n" + _RESULTS + "\n===============\n";
    integer votes_length = llGetListLength(votes);
    if (votes_length > 0)
    {
        integer i = 0;
        string code = "";
        string value = "";
        while(i < votes_length)
        {
            code = llList2String(votes, i);
            value = llList2String(votes, (i+1));
            text += code + " : " + value + "\n";
            if (code == _YES)
            {
                yes_votes++;
            }
            else if (code == _NO)
            {
                no_votes++;
            }
            else
            {
                abst_votes++;
            }
            i = i + 2;
        }
    }
    else
    {
        text += _NO_VOTES;
    }
    llSay(0, text);
}

default
{
    on_rez(integer start_param)
    {
        llResetScript();
    }

    changed(integer change)
    {
        if(change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            llResetScript();
        }
    }

    state_entry()
    {
        owner = llGetOwner();
        init();
        listenHandler = llListen(LISTEN_CHANNEL, "", "", "");
    }

    dataserver(key request_id, string data)
    {
        if(request_id == notecardQueryId)
        {
            readNotecard(data);
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        parseCommand(id, message);
    }
}

state start
{
    on_rez(integer start_param)
    {
        llResetScript();
    }

    changed(integer change)
    {
        if(change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            llResetScript();
        }
    }

    state_entry()
    {
        llSay(0, "\n===============\n" + _VOTE_READY + "\n===============");
        llSetText(_READY_TO_VOTE, <0.0, 1.0, 0.0>, 1.0);
        llSetColor(<0.0, 0.0, 0.0>, ALL_SIDES);
        listenHandler = llListen(LISTEN_CHANNEL, "", "", "");
    }

    touch_start(integer num_detected)
    {
        voter = llDetectedKey(0);
        vote = llDetectedLinkNumber(0);
        if (vote > 1)
        {
            state vote;
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        parseCommand(id, message);
    }
}

state vote
{
    on_rez(integer start_param)
    {
        llResetScript();
    }

    changed(integer change)
    {
        if(change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            llResetScript();
        }
    }

    state_entry()
    {
        llSetText(_VOTING, <1.0, 0.0, 0.0>, 1.0);
        llSetColor(<1.0, 0.0, 0.0>, ALL_SIDES);
        listenHandler = llListen(LISTEN_CHANNEL, "", "", "");
        recordVote();
    }

    listen(integer channel, string name, key id, string message)
    {
        parseCommand(id, message);
    }
}

state display_infos
{
    on_rez(integer start_param)
    {
        llResetScript();
    }

    changed(integer change)
    {
        if(change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            llResetScript();
        }
    }

    state_entry()
    {
        llSetText(_DISPLAYING_INFOS, <1.0, 0.0, 0.0>, 1.0);
        llSetColor(<1.0, 0.0, 0.0>, ALL_SIDES);
        listenHandler = llListen(33, "", "", "");
        displayInfos(1, 1);
    }

    listen(integer channel, string name, key id, string message)
    {
        parseCommand(id, message);
    }
}

state stop
{
    on_rez(integer start_param)
    {
        llResetScript();
    }

    changed(integer change)
    {
        if(change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            llResetScript();
        }
    }

    state_entry()
    {
        llSetText(_STOP, <1.0, 0.0, 0.0>, 1.0);
        llSetColor(<1.0, 0.0, 0.0>, ALL_SIDES);
        llSetLinkPrimitiveParamsFast(2, [
            PRIM_TEXT, "", ZERO_VECTOR, 0.0,
            PRIM_COLOR, ALL_SIDES, <1.0, 0.0, 0.0>, 0.0]);
        llSetLinkPrimitiveParamsFast(3, [
            PRIM_TEXT, "", ZERO_VECTOR, 0.0,
            PRIM_COLOR, ALL_SIDES, <1.0, 0.0, 0.0>, 0.0]);
        llSetLinkPrimitiveParamsFast(4, [
            PRIM_TEXT, "", ZERO_VECTOR, 0.0,
            PRIM_COLOR, ALL_SIDES, <1.0, 0.0, 0.0>, 0.0]);
        listenHandler = llListen(LISTEN_CHANNEL, "", "", "");
        displayInfos(0, 1);
        displayResults();
    }

    listen(integer channel, string name, key id, string message)
    {
        parseCommand(id, message);
    }
}
