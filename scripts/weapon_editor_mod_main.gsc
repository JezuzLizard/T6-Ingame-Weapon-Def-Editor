#include maps\mp\zombies\_zm_weapons;

/*
	Functions:

	getAllLoadedWeaponNames() - Returns an array of all weapon names that have been precached
	You can then use dumpweapon(), parseweapon(), getweaponfield(), and setweaponfield() on these weapons

	dumpWeapon( <weapon_name>, <path> ) - Dumps a partial weapon def of the input weapon to the path

	parseWeapon( <weapon_name>, <path> ) - Parses a partial weapon def dumped by weapon def will script error if parsing fails

	setWeaponField( <weapon_name>, <field_name>, <value> ) - Sets an individual weapon field of a weapon to <value>
	Will script error if value type isn't the same as the field type, expects enum values to be strings

	getWeaponField( <weapon_name>, <field_name> ) - Gets the value of the field on the weapon def as it currently is set to
*/



init()
{
	//Path used for dumping weapon defs goes in storage/t6/
	level.weapon_dump_path = "asset_dumps/weapons/zm/" + getDvar( "mapname" );
	//Path used for parsing edited weapon defs goes in storage/t6/
	level.weapon_parse_path = "modified_assets/weapons/zm/" + getDvar( "mapname" );
	level thread command_thread();

	//Gets all weapons that have been precached by script at some point
	//Need to call this in init() so everything has already been precached
	level.loaded_weapon_names = getAllLoadedWeaponNames();

	//Automatically dump and parse all weapons at runtime
	foreach ( weapon_name in level.loaded_weapon_names )
	{
		if ( weapon_name == "" )
		{
			continue;
		}
		dumpWeapon( weapon_name, level.weapon_dump_path );

		path = level.weapon_parse_path;
		file = path + "/" + weapon_name + ".json";
		if ( fileExists( file ) )
		{
			parseWeapon( weapon_name, path );
		}
	}

	example_1();
	example_2();
	example_3();
	example_4();
	example_5();
	example_6();

	make_warmachine_explode_on_impact();
}

example_1()
{
	foreach ( weapon_name in level.loaded_weapon_names )
	{
		cur_firetime = getWeaponField( weapon_name, "firetime" );
		new_firetime = int( cur_firetime * 0.69 );
		setWeaponField( weapon_name, "firetime", new_firetime );
	}
}

example_2()
{
	foreach ( weapon_name in level.loaded_weapon_names )
	{
		cur_damage = getWeaponField( weapon_name, "damage" );
		new_damage = int( cur_damage * 1.33 );
		setWeaponField( weapon_name, "damage", new_damage );

		setWeaponField( weapon_name, "maxDamageRange", 999999 );

		setWeaponField( weapon_name, "minDamageRange", 999999 );
	}
}

example_3()
{
	foreach ( weapon_name in level.loaded_weapon_names )
	{
		cur_firetype = getWeaponField( weapon_name, "firetype" );
		if ( toLower( cur_firetype ) == "single shot" )
		{
			setWeaponField( weapon_name, "firetype", "full auto" );
		}
	}
}

example_4()
{
	foreach ( weapon_name in level.loaded_weapon_names )
	{
		cur_lochead = getWeaponField( weapon_name, "lochead" );
		new_lochead = cur_lochead * 1.5;
		setWeaponField( weapon_name, "lochead", new_lochead );
	}
}

example_5()
{
	foreach ( weapon_name in level.loaded_weapon_names )
	{
		setWeaponField( weapon_name, "doGibbing", true );
	}
}

example_6()
{
	foreach ( weapon_name in level.loaded_weapon_names )
	{
		cur_clipsize = getWeaponField( weapon_name, "clipsize" );
		new_clipsize = int( cur_clipsize * 1.25 );
		setWeaponField( weapon_name, "clipsize", new_clipsize );
	}
}

make_warmachine_explode_on_impact()
{
	if ( sessionmodeIsZombiesGame() )
	{
		setWeaponField( "m32_zm", "projImpactExplode", true );
	}
}

command_thread()
{
	while ( true )
	{
		level waittill( "say", message, player, ishidden );
		//By default / commands are used
		if ( !ishidden )
		{
			continue;
		}
		commands = strTok( message, " " );
		switch ( commands[ 0 ] )
		{
			case "setweaponfield":
				if ( commands.size < 4 )
				{
					player iPrintln( "Usage: /weaponfield <weapon> <field> <value>" );
					continue;
				}
				if ( is_str_int( commands[ 2 ] ) )
				{
					value = int( commands[ 2 ] );
				}
				else if ( is_str_float( commands[ 2 ] ) )
				{
					value = float( commands[ 2 ] );
				}
				else 
				{
					value = "";
					for ( i = 3; i < commands.size; i++ )
					{
						if ( isDefined( commands[ i ] ) )
						{
							if ( i == commands.size - 1 )
							{
								value += commands[ i ];
							}
							else 
							{
								value += commands[ i ] + " ";
							}
						}
					}
				}
				cmd_setweaponfield( commands[ 1 ], commands[ 2 ], value, player );
				break;
			case "getweaponfield":
				if ( commands.size < 3 )
				{
					player iPrintln( "Usage: /weaponfield <weapon> <field>" );
					continue;
				}
				found_weapon = false;
				foreach ( weapon_name in level.loaded_weapon_names )
				{
					if ( commands[ 1 ] == weapon_name )
					{
						found_weapon = true;
						break;
					}
				}
				if ( !found_weapon )
				{
					player iPrintLn( "Weapon " + commands[ 1 ] + " is invalid" );
					continue;
				}
				player iPrintLn( "Weapon " + commands[ 1 ] + " " + commands[ 2 ] + " is " + getWeaponField( commands[ 1 ], commands[ 2 ] ) );
				break;
			case "resetweapons":
				foreach ( weapon in level.loaded_weapon_names )
				{
					path = level.weapon_dump_path;
					file = path + "/" + weapon + ".json";
					if ( fileExists( file ) )
					{
						parseWeapon( weapon, path );
					}
					else 
					{
						print( "While attemping to reset weapons " + weapon + " doesn't exist in " + path );
					}
				}
				break;
			case "reloadweapons":
				foreach ( weapon in level.loaded_weapon_names )
				{
					path = level.weapon_parse_path;
					file = path + "/" + weapon + ".json";
					print( "Attempting to reload " + weapon );
					if ( fileExists( file ) )
					{
						print( "Reloaded " + weapon );
						parseWeapon( weapon, level.weapon_parse_path );
					}
				}
				break;
			case "parseweapon":
				if ( commands.size < 2 )
				{
					player iPrintln( "Usage: /parseweapon <weapon>" );
					continue;
				}
				path = level.weapon_parse_path;
				file = path + "/" + commands[ 1 ] + ".json";
				if ( !fileExists( file ) )
				{
					player iPrintLn( "weapon " + commands[ 1 ] + " doesn't in " + path );
					continue;
				}
				parseWeapon( commands[ 1 ], level.weapon_parse_path );
				break;
			case "saveweapon":
				if ( commands.size < 2 )
				{
					player iPrintln( "Usage: /saveweapon <weapon>" );
					continue;
				}
				dumpWeapon( commands[ 1 ], level.weapon_parse_path );
				break;
			case "weapon":
				if ( commands.size < 2 )
				{
					player iPrintLn( "Usage: /give <weapon>" );
					continue;
				}
				player weapon_give( commands[ 1 ] );
				break;
		}
	}
}

cmd_setweaponfield( weapon, field, value, player )
{
	found_weapon = false;
	foreach ( weapon_name in level.loaded_weapon_names )
	{
		if ( weapon == weapon_name )
		{
			found_weapon = true;
			break;
		}
	}
	if ( !found_weapon )
	{
		if ( isDefined( player ) )
		{
			player iPrintLn( "Weapon " + weapon + " is invalid" );
			return;
		}
	}
	setWeaponField( weapon, field, value );
	if ( isDefined( player ) )
	{
		player iPrintLn( "Set " + weapon + " " + field + " to " + value );
	}
}

is_str_int( str )
{
	numbers = [];
	for ( i = 0; i < 10; i++ )
	{
		numbers[ i + "" ] = i;
	}
	negative_sign[ "-" ] = true;
	if ( isDefined( negative_sign[ str[ 0 ] ] ) )
	{
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}
	for ( i = start_index; i < str.size; i++ )
	{
		if ( !isDefined( numbers[ str[ i ] ] ) )
		{
			return false;
		}
	}
	return true;
}

is_str_float( str )
{
	numbers = [];
	for ( i = 0; i < 10; i++ )
	{
		numbers[ i + "" ] = i;
	}
	negative_sign[ "-" ] = true;
	if ( isDefined( negative_sign[ str[ 0 ] ] ) )
	{
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}
	period[ "." ] = true;
	periods_found = 0;
	if ( isDefined( period[ str[ str.size - 1 ] ] ) )
	{
		return false;
	}
	for ( i = start_index; i < str.size; i++ )
	{
		if ( isDefined( period[ str[ i ] ] ) )
		{
			periods_found++;
			if ( periods_found > 1 )
			{
				return false;
			}
			continue;
		}
		if ( !isDefined( numbers[ str[ i ] ] ) )
		{
			return false;
		}
	}
	if ( periods_found == 0 )
	{
		return false;
	}
	return true;
}
