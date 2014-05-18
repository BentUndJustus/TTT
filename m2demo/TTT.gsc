#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;



Respawn() {
//Varset

////////////////
	// if (self.counter==0) {level GetTraitor(); self.counter++;}
	// else{
		SpawnWeapons();
		
		self thread ThrowWeaponaway();
		
		self thread bombFix();
		self takeAllWeapons();
		//level thread Rundenzaehler();
		
		
		self.hasWeapon=0;
	// }
}

Connect () {
	self.counter=0;
	self maps\mp\gametypes\_menus::addToTeam("allies"); 
	self thread Notify();
	self clearPerks();

	self thread DoText();
	
	

}

DoText() {
	self.hud = createRectangle("BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, 180, 60, (0.40, 0.40, 0.40), "white",0 ,0.5);
	self.menuopti = self createFontString( "default", 1.5, self );
	self.menuopti setPoint("BOTTOMRIGHT", "BOTTOMRIGHT", -5, -30);	
	self.menuopti setText("Preparing...");	



}


Rundenzaehler() {
	while (1) 
	{
		level.traitorcount=0;
		//self.menuopti setText("Preparing...");	
		level GetTraitor();	
		wait 0.1;
		level waittill ( "round_end_finished" );
	}
}


GetTraitor() {
	
	
	rand = randomInt(level.players.size);
	
	level.players[rand].traitor=1;
	
	
	foreach(player in level.players)
	{
		if(player.traitor==1 && level.traitorcount==0) 
		{	
			
			self thread ShowTraitor(player);
			level.traitorcount++;
			self thread Traitortester(player);

		}
		else
		{	
			
			self thread ShowInnocent(player);
			
		}
		
		deathcounter=0;

	}	
}

ShowTraitor(player) {
	
	 if (player==self)
	 {
		wait 10;
		self.menuopti setText("^1Traitor");
	 }
	
}

ShowInnocent(player) {
	
	 if (player==self) 
	 {
		wait 10;
		self.menuopti setText("^2Innocent");
	 }
	
}



ConfigPlayer() {
		self waittill("spawned_player");
		wait 1;
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
			if(distance(location, player.origin) < 50 && player.hasWeapon==1) {
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
		if(self getCurrentWeapon() == "briefcase_bomb_mp")
		{
			self takeWeapon("briefcase_bomb_mp");
			self iPrintlnBold("^1NO PLANTING"); 
		}
			wait 0.05;
	 }
}

// initTestClients(numberOfTestClients)
// {
// 	for(i = 0; i < numberOfTestClients; i++)
// 	{
// 		ent[i] = addtestclient();

// 		if (!isdefined(ent[i]))
// 		{
// 			wait 1;
// 			continue;
// 		}

// 		ent[i].pers["isBot"] = true;
// 		ent[i] thread initIndividualBot();
// 		wait 0.1;
// 	}
// }

Traitortester(player) {
	level.deathcounter=0;

	while (1) {
		wait 0.01;
		if (player.health<1)
		{
			
				
				iPrintlnBold("^2Innocents WIN");
				maps\mp\gametypes\_gamelogic::forceEnd();

			

		}

		else {

			foreach (player in level.players) 
			{
				if (player.health<1) {
					level.deathcounter++;
				}
			}
			if (level.deathcounter>level.players.size-2)
			{
				
				
				iPrintlnBold("^1Traitors WIN");
				maps\mp\gametypes\_gamelogic::forceEnd();
				
			}

		}
			
	}



}



createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
    boxElem = newClientHudElem(self);
    boxElem.elemType = "bar";
    if(!level.splitScreen)
    {
        boxElem.x = -2;
        boxElem.y = -2;
    }
    boxElem.width = width;
    boxElem.height = height;
    boxElem.align = align;
    boxElem.relative = relative;
    boxElem.xOffset = 0;
    boxElem.yOffset = 0;
    boxElem.children = [];
    boxElem.sort = sort;
    boxElem.color = color;
    boxElem.alpha = alpha;
    boxElem.shader = shader;
    boxElem setParent(level.uiParent);
    boxElem setShader(shader, width, height);
    boxElem.hidden = false;
    boxElem setPoint(align, relative, x, y);
    return boxElem;
}



