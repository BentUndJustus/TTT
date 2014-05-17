Respawn() {
//Varset

////////////////
	self thread SpawnWeapons();
	self thread SpawnAmmunation();
	self thread ThrowWeaponaway();
	self thread CollectWeapon();
	self takeAllWeapons();


}

Connect () {
	self thread Notify();

	




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

				player setWeaponAmmoOverall(currentWeapon, player getAmmoCount(currentWeapon)+10);
				
				
				model delete();
				return;
			}
		}
	}




}

WeaponThink(weapon, location, model,ammo)
{
	
	
	while(1)
	{

		wait 0.1;
		foreach(player in level.players)
		{
			if(distance(location, player.origin) < 50)
			{
					player giveWeapon(weapon, 10,false);
					//player SetWeaponAmmoStock(weapon, 10);
					//player SetWeaponAmmoClip(weapon, 0);
					player setWeaponAmmoOverall(weapon, ammo);
					player switchToWeapon( weapon );
					player.ammo=10;

					
					model delete();
					
					return;
					
						
			}
		}
	}
}


SpawnWeapons () {


self takeAllWeapons();
weapona = self CreateWeapon("ak47_mp",self.origin,(0,90,0),10);	
ammoa = self CreateAmmo(self.origin+(0,60,0),(0,60,0));




}

SpawnAmmunation() {



}

ThrowWeaponaway() {
	self endon ("death");
	while(1) {
		self notifyOnPlayerCommand("n", "+actionslot 1");
		self waittill("n");
		self endon("disconnect");

		cweapon = self getCurrentWeapon();
		self CreateWeapon(cweapon,self.origin+(0,60,0),(0,0,10),self getAmmoCount( cWeapon ));	
		iPrintlnBold(self.origin);
		self takeWeapon( CWeapon );
	}


}

CollectWeapon() {

	
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
setWeaponAmmoOverall( weaponname, amount )
{
	if ( isWeaponClipOnly( weaponname ) )
	{
		self setWeaponAmmoClip( weaponname, amount );
	}
	else
	{
		self setWeaponAmmoClip( weaponname, amount );
		diff = amount - self getWeaponAmmoClip( weaponname );
		assert( diff >= 0 );
		self setWeaponAmmoStock( weaponname, diff );
	}
}







