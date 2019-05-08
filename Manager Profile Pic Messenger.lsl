
list sides;
list deftextures;

string profile_key_prefix = "<meta name=\"imageid\" content=\"";
string profile_img_prefix = "<img alt=\"profile image\" src=\"http://secondlife.com/app/image/";
integer profile_key_prefix_length; // calculated from profile_key_prefix in state_entry()
integer profile_img_prefix_length; // calculated from profile_key_prefix in state_entry()

string getDesc;
key descKey;
key onlinerequest;
string owner_name = "Owner ";
key owner_name_query;

integer online = FALSE;

init()
{
	//llSetText("Initializing...", <1,1,1>, 1);
	getDesc = llGetObjectDesc();
	descKey = (key)getDesc;
	GetProfilePic(descKey);
	profile_key_prefix_length = llStringLength(profile_key_prefix);
	profile_img_prefix_length = llStringLength(profile_img_prefix);
	GetDefaultTextures();
	owner_name_query = llRequestAgentData(descKey, DATA_NAME);
	llSetTimerEvent(5);
}

GetProfilePic(key id) //Run the HTTP Request then set the texture
{
	//key id=llDetectedKey(0); This breaks the function, better off not used
	string URL_RESIDENT = "http://world.secondlife.com/resident/";
	llHTTPRequest( URL_RESIDENT + (string)id,[HTTP_METHOD,"GET"],"");
}

GetDefaultTextures() //Get the default textures from each side
{
	integer    i;
	integer    faces = llGetNumberOfSides();
	for (i = 0; i < faces; i++)
	{
		sides+=i;
		deftextures+=llGetTexture(i);
	}
}

SetDefaultTextures() //Set the sides to their default textures
{
	integer    i;
	integer    faces;
	faces = llGetNumberOfSides();
	for (i = 0; i < faces; i++)
	{
		llSetTexture(llList2String(deftextures,i),i);
	}
}

default
{

	state_entry()
	{
		init();
	}

	touch_start(integer total_number)
	{
		init();
		llInstantMessage(llDetectedKey(0), "Click here to learn more about and send a message to: secondlife:///app/agent/" + getDesc + "/about");
	}

	http_response(key req,integer stat, list met, string body)
	{
		integer s1 = llSubStringIndex(body, profile_key_prefix);
		integer s1l = profile_key_prefix_length;
		if(s1 == -1)
		{ // second try
			s1 = llSubStringIndex(body, profile_img_prefix);
			s1l = profile_img_prefix_length;
		}

		if(s1 == -1)
		{ // still no match?
			SetDefaultTextures();
		}
		else
		{
			s1 += s1l;
			key UUID=llGetSubString(body, s1, s1 + 35);
			if (UUID == NULL_KEY) {
				SetDefaultTextures();
			}
			else {
				llSetTexture(UUID,3);
			}
		}
	}

	dataserver(key request, string data)
	{
		if (request == owner_name_query) {
			owner_name = data;
			llSetObjectName(owner_name);
		} else {
			if (data == "1") {
				llSetTexture("0bbf4dd5-e60f-ae3e-0fa0-11cdfa9a563a", 1);
				online = TRUE;
			} else {
				llSetTexture("2b904e42-47cc-7596-62a4-fbbac28483a8", 1);
				online = FALSE;
			}
		}
	}

	timer()
	{
		onlinerequest = llRequestAgentData(descKey, DATA_ONLINE);
	}
}

// MIT LICENSE
// Copyright (c) 2014, MJ Dunn <mjdunnonline@gmail.com>

// Branched from _Get Profile Picture by Valentine Foxdale_