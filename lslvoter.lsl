// @version lslvoter
// @package lslvoter
// @copyright Copyright wene / ssm2017 Binder (C) 2014. All rights reserved.
// @license http://www.gnu.org/licenses/gpl-2.0.html GNU/GPL, see LICENSE.php
// lslvoter is free software and parts of it may contain or be derived from the
// GNU General Public License or other free or open source software licenses.

// #######################
//     STRINGS
// #######################
string _H1 = "\n==========================\n";
string _H2 = "\n--------------------------\n";
string _YES = "Yes";
string _NO = "No";
string _ABST = "Abstention";
string _NOT_DEFINED = "Not defined";
string _VOTE_NAME_ALREADY_DEFINED = "Vote name already defined";
string _WAIT_FOR_NAME = "Waiting for the vote name";
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
string _VOTE_NOT_READY = "Vote not ready";
string _WRONG_VOTE_VALUE = "Wrong vote value";
// infos
string _DISPLAYING_INFOS = "Displaying infos";
string _VOTE_NAME = "Vote name";
string _INFOS = "Infos";
string _MY_INFOS = "My infos";
string _AVATAR_INFOS = "Avatar infos";
string _CHAT_VOTE_INFOS = "Chat vote infos";
string _CHAT_VOTE_CODE = "Chat vote code";
string _VOTE_INFOS = "Vote infos";
string _MY_KEY_IS = "My key is";
string _MY_NAME_IS = "My name is";
string _MY_CODE_IS = "My code is";
string _MY_VOTE_IS = "My vote is";
string _VOTE_YES_BY_CHAT = "Vote Yes by chat";
string _VOTE_NO_BY_CHAT = "Vote No by chat";
string _VOTE_ABST_BY_CHAT = "Vote Abstention by chat";
// help
string _HELP = "Help";
string _HELP_HELP = "Displays this help message";
string _HELP_MY = "Displays my personnal infos (uuid, name, code, vote)";
string _HELP_VOTE = "Allows you to vote using the command line instead of touching the object";
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
integer vote_ready = 0;
// users
key owner;
// vote
string vote_name = "";
list presents = [];
list absents = [];
list votes = [];
list votes_values = [];
key voter;
integer vote;
string vote_code;
// vote type : 1 = touch, 2 = chat
integer vote_type;

// init
init()
{
    llSay(0, _H1 + _INITIALISATION +  _H1);
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


// notecard
key notecardQueryId;
integer line;
readNotecard(string data)
{
    //  if we are at the end of the file
    if(data == EOF)
    {
        llSay(0, _NOTECARD_READ);
        state wait_name;
    }
    else
    {
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
}

sortAvatar(string name, key id)
{
    string realName = llKey2Name(id);
    if (realName != "")
    {
        // id, vote_code, yes_code, no_code, abst_code
        presents = presents + [id, realName, randomCodeGenerator(4), randomCodeGenerator(4), randomCodeGenerator(4), randomCodeGenerator(4)];
    }
    else
    {
        absents = absents + [name];
    }
}

// random code generator
// source : http://wiki.secondlife.com/wiki/Random_Password_Generator
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

list getVoterInfos(key id)
{
    // check if voter is in presents list
    integer presents_index = llListFindList(presents, [id]);
    if (presents_index != -1)
    {
        // get the voter infos
        return llList2List(presents, presents_index, presents_index + 5);
    }
    else
    {
        return [];
    }
}

// vote
recordVote()
{
    // get the voter infos
    list voter_infos = getVoterInfos(voter);
    if (voter_infos != [])
    {
        // get the vote value
        if (vote_type == 2)
        {
            integer vote_code_value = llListFindList(voter_infos, [vote_code]);
            if (vote_code_value != -1)
            {
                vote = vote_code_value - 3;
            }
            else
            {
                llInstantMessage(voter, _WRONG_VOTE_VALUE);
                state start;
            }
        }

        // check if the user has already voted
        string voter_name = llList2String(voter_infos, 1);
        string voter_code = llList2String(voter_infos, 2);
        string vote_value = llList2String(votes_values, vote);
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
            if (vote_name == _NOT_DEFINED)
            {
                vote_name = value;
                llSay(0, _NAME_DEFINED_TO + " : " + vote_name);
            }
            else
            {
                llSay(0, _VOTE_NAME_ALREADY_DEFINED);
            }
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
        if (vote_ready)
        {
            vote_type = 2;
            voter = id;
            if (value != "")
            {
                vote_code = value;
                state vote;
            }
            else
            {
                llInstantMessage(id, _WRONG_VOTE_VALUE);
            }
        }
        else
        {
            llInstantMessage(id, _VOTE_NOT_READY);
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
                        "/" + LISTEN_CHANNEL + " vote:<" + _CHAT_VOTE_CODE + ">\n" +
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
    // get the voter infos
    list voter_infos = getVoterInfos(id);
    if (voter_infos != [])
    {
        string my_key = (string)id;
        string my_name = llList2String(voter_infos, 1);
        string my_code = llList2String(voter_infos, 2);
        string my_yes_code = llList2String(voter_infos, 3);
        string my_no_code = llList2String(voter_infos, 4);
        string my_abst_code = llList2String(voter_infos, 5);

        string my_vote = _NO_VOTE_YET;
        integer votes_index = llListFindList(votes, [my_code]);
        if (votes_index != -1)
        {
            my_vote = llList2String(votes, (votes_index + 1));
        }
        string text = _H1 + _MY_INFOS + _H1;
        if (full)
        {
            text += _AVATAR_INFOS + _H2 +
                    _MY_KEY_IS + " : " + my_key + "\n" +
                    _MY_NAME_IS + " : " + my_name +
                    _H2 +
                    _CHAT_VOTE_INFOS + _H2 +
                    _VOTE_YES_BY_CHAT + " :\n/" + LISTEN_CHANNEL + " vote:" + my_yes_code + "\n\n" +
                    _VOTE_NO_BY_CHAT + " :\n/" + LISTEN_CHANNEL + " vote:" + my_no_code + "\n\n" +
                    _VOTE_ABST_BY_CHAT + " :\n/" + LISTEN_CHANNEL + " vote:" + my_abst_code +
                    _H2;
        }
        text += _VOTE_INFOS + _H2 +
                _MY_CODE_IS + " : " + my_code + "\n" +
                _MY_VOTE_IS + " : " + my_vote +
                _H2;
        llInstantMessage(id, text);
    }
    else
    {
        llInstantMessage(id, _NOT_ALLOWED);
    }
}

displayInfos(integer go_to_start, integer show_non_voted)
{
    string infos = _H1 + _INFOS + _H1;
    infos += _VOTE_NAME + " : " + vote_name;

    // show presents
    integer presents_count = 0;
    integer presents_length = llGetListLength(presents);
    infos += _H2 + _PRESENTS + _H2;
    integer i = 0;
    while(i < presents_length)
    {
        infos += llList2String(presents, (i+1)) + "\n";
        i = i + 6;
        presents_count++;
    }
    infos += _PRESENTS + " : (" + presents_count + ")\n";

    // show absents
    integer absents_count = 0;
    integer absents_length = llGetListLength(absents);
    infos += _H2 + _ABSENTS + _H2;
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
        infos += _H2 + _NON_VOTED + _H2;
        i = 0;
        while(i < presents_length)
        {
            // check if user has voted
            if (llListFindList(votes, [llList2String(presents, (i+2))]) == -1)
            {
                infos += llList2String(presents, (i+1)) + "\n";
                non_voted_count++;
            }
            i = i + 6;
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
    string text = _H1 + _RESULTS + _H1;
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
        vote_ready = 0;
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

state wait_name
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
        llSay(0, _H1 + _WAIT_FOR_NAME + _H1);
        listenHandler = llListen(LISTEN_CHANNEL, "", "", "");
        vote_ready = 0;
    }

    touch_start(integer num_detected)
    {
        if (llDetectedKey(0) == owner && vote_name != _NOT_DEFINED)
        {
            displayInfos(1, 0);
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
        llSay(0, _H2 + _VOTE_READY + _H2);
        llSetText(_READY_TO_VOTE, <0.0, 1.0, 0.0>, 1.0);
        llSetColor(<0.0, 0.0, 0.0>, ALL_SIDES);
        listenHandler = llListen(LISTEN_CHANNEL, "", "", "");
        vote_ready = 1;
    }

    touch_start(integer num_detected)
    {
        vote_type = 1;
        voter = llDetectedKey(0);
        vote = (llDetectedLinkNumber(0) - 2);
        if (vote >= 0)
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
        vote_ready = 0;
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
        vote_ready = 0;
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
        vote_ready = 0;
        displayInfos(0, 1);
        displayResults();
    }

    listen(integer channel, string name, key id, string message)
    {
        parseCommand(id, message);
    }
}
