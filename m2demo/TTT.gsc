#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;



Respawn() {
//Varset

////////////////
	SpawnWeapons();
	// self thread SpawnAmmunation();
	self thread ThrowWeaponaway();
	
	self thread bombFix();
	self takeAllWeapons();
	level thread Rundenzaehler();
	thread ConfigPlayer();
	self.hasWeapon=0;

}

Connect () {

	
	self thread Notify();
	self clearPerks();

	level GetTraitor();




}

Rundenzaehler() {
	while (1) 
	{
		level waittill ( "round_end_finished" );
		level.traitorcount=0;
		wait 0.1;
		GetTraitor();	
	}
}


GetTraitor() {
	
	rand = randomInt(level.players.size);
	iPrintlnBold(rand);
	level.players[rand].traitor=1;

	
	foreach(player in level.players)
	{
		if(player.traitor==1 && level.traitorcount==0) 
		{
			self.switching_teams = true;
			self.joining_team = "axis";
			self.leaving_team = self.pers["team"];
			self suicide();
			self maps\mp\gametypes\_menus::addToTeam("axis");
			player iPrintlnBold("You are ^1Traitor");
			level.traitorcount++;


		}
		else
		{
			self.switching_teams = true;
			self.joining_team = "allies";
			self.leaving_team = self.pers["team"];
			self suicide();
			self maps\mp\gametypes\_menus::addToTeam("allies"); 
			player iPrintlnBold("You are ^2Innocent");
		}
		
		
		player setClientDvar("cg_scoreboardHeight","1");
		player setClientDvar("ui_allow_classchange","0");
		player setClientDvar("ui_allow_teamchange","0");

	}	
}

ConfigPlayer() {
		self waittill("spawned_player");
		wait 0.1;
		self SetOrigin(-597,-290,7);
		self takeAllWeapons();
		self clearPerks();


}

CreateWeapon(weapon, location, angle, ammo)
{
	weaponModel = getWeaponModel( weapon );

	if( weaponModel == "" )
		weaponModel = weapon;

	if(!isDefined(angle))
		angle = 0;

	weaponSpawn = spawn( "script_model", location );
	weaponSpawn setModel( weaponModel );
	weaponSpawn.angles = angle;

	self thread WeaponThink(weapon, location, weaponSpawn, ammo);
	wait 0.01;
	return weaponSpawn;
}

CreateAmmo(location) {
	modelSpawn = spawn ("script_model", location);
	modelSpawn setModel("com_cellphone_on");

	self thread AmmoThink(location, modelSpawn);
	wait 0.01;
	return modelSpawn;

}

AmmoThink(location, model) {
	while(1) {
		wait 0.1;
		foreach(player in level.players)
		{
			if(distance(location, player.origin) < 50) {
				currentWeapon = player getCurrentWeapon();

				player setWeaponAmmoOverall(currentWeapon, 10, player);
				
				
				model delete();
				return;
			}
		}
	}




}

WeaponThink(weapon, location, model, ammo)
{
	
	
	while(1)
	{

		wait 0.1;
		foreach(player in level.players)
		{
			if(distance(location, player.origin) < 50 && player.hasWeapon != 1)
			{
					player giveWeapon(weapon, 10,false);
					player SetWeaponAmmoStock(weapon, 0);
					player SetWeaponAmmoClip(weapon, 0);
					player setWeaponAmmoOverall(weapon, ammo, player);
					player switchToWeapon( weapon );
					player.hasWeapon=1;
					
					model delete();
					
					return;
					
						
			}
		}
	}
}


SpawnWeapons () {


self takeAllWeapons();
spawnpoints = self spawnpoints::Favela();
weapons = self spawnpoints::Weapons();
for(i=0;i<spawnpoints.size;i++)
{
	if( randomInt(2)==1)
	{	
		randweapon = weapons[randomInt(weapons.size)];
		spawned[i] = self CreateWeapon(randweapon,spawnpoints[i]+(0,0,3),(0,90,0),10);
	}
	else 
	{
		spawned[i] = self CreateAmmo(spawnpoints[i],(0,60,0));
	}

}





}

SpawnAmmunation() {



}

ThrowWeaponaway() {
	self endon ("death");
	self endon("disconnect");
	while(1) {
		self notifyOnPlayerCommand("n", "+actionslot 1");
		self waittill("n");
		

		cweapon = self getCurrentWeapon();
		self CreateWeapon(cweapon,self.origin+(0,60,0),(0,0,10),self getAmmoCount( cWeapon ));	
		self iPrintlnBold(self.origin);
		self takeWeapon( CWeapon );
		self.hasWeapon=0;
	}


}



Notify()
{
	self notifyOnPlayerCommand("n", "+actionslot 1");
	self notifyOnPlayerCommand("action4", "+actionslot 2");
	self notifyOnPlayerCommand("k", "+actionslot 4");
	self notifyOnPlayerCommand("g", "+frag");
	self notifyOnPlayerCommand("switch", "+activate");
	self notifyOnPlayerCommand("more", "+melee");

}

// sets the amount of ammo in the gun.
// if the clip maxs out, the rest goes into the stock.
setWeaponAmmoOverall( weaponname, amount, player)
{
		vorher = player getWeaponAmmoClip(weaponname); 
		clipSize = weaponClipSize(weaponname);	
		diffclip = clipSize-vorher; 

		if (clipSize-vorher < amount) 
		{
			iPrintlnBold(amount-(clipSize-vorher));
			amount = amount-(clipSize-vorher);
			player SetWeaponAmmoClip(weaponname, clipSize);
			player SetWeaponAmmoStock(weaponname, amount);
		}

		else 
		{
			player SetWeaponAmmoClip(weaponname, vorher+amount);
		}

}

bombFix() // Prevent bomb planting
{
self endon("death");
self endon("disconnect");
 
startweapon = self getCurrentWeapon();
startoffhand = self getCurrentOffhand();
wait 5;
while(1){
if(self getCurrentWeapon() == "briefcase_bomb_mp"){
self takeWeapon("briefcase_bomb_mp");
self iPrintlnBold("^1NO PLANTING"); }
wait 0.05; }
}








