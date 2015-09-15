/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox0"
	desc = "A display case for prized possessions."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/destroyed = 0
	var/obj/item/showpiece = null
	var/alert = 0
	var/open = 0

/obj/structure/displaycase/ex_act(severity, target)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			dump()
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()

/obj/structure/displaycase/examine(mob/user)
	..()
	if(showpiece)
		user << "<span class='notice'>There's [showpiece] inside.</span>"
	if(alert)
		user << "<span class='notice'>Hooked up with an anti-theft system.</span>"


/obj/structure/displaycase/bullet_act(obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
	..()
	src.healthcheck()
	return

/obj/structure/displaycase/proc/dump()
	if (showpiece)
		showpiece.loc = src.loc
		showpiece = null

/obj/structure/displaycase/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		dump()
		qdel(src)

/obj/structure/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			update_icon()

			//Activate Anti-theft
			if(alert)
				var/area/alarmed = get_area(src)
				alarmed.burglaralert(src)
				playsound(src, "sound/effects/alert.ogg", 50, 1)

	else
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/displaycase/update_icon()
	var/icon/I = icon('icons/obj/stationobjs.dmi',"glassbox[destroyed || open?"b":""]0")
	if(showpiece)
		var/icon/S = getFlatIcon(showpiece) //Guns got overlays
		S.Scale(17,17)
		I.Blend(S,ICON_UNDERLAY,8,8)
	src.icon = I
	return

/obj/structure/displaycase/attackby(obj/item/weapon/W, mob/user, params)
	if(!alert && istype(W,/obj/item/weapon/crowbar))
		if(destroyed && !showpiece)
			user << "<span class='notice'>You remove the destroyed case</span>"
			qdel(src)
			return
		user << "<span class='notice'>You start to [open ? "close":"open"] the [src]</span>"
		if(do_after(user, 20, target = src))
			open = !open
			user <<  "<span class='notice'>You  [open ? "close":"open"] the [src]</span>"
			update_icon()
	else if(open)
		if(user.unEquip(W))
			W.loc = src
			showpiece = W
			user << "<span class='notice'>You put [W] on display</span>"
			update_icon()
	else
		user.changeNext_move(CLICK_CD_MELEE)
		src.health -= W.force
		src.healthcheck()
		..()
	return

/obj/structure/displaycase/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if (showpiece && (destroyed || open))
		dump()
		user << "<span class='notice'>You deactivate the hover field built into the case.</span>"
		src.add_fingerprint(user)
		update_icon()
		return
	else
		user.visible_message("<span class='danger'>[user] kicks the display case.</span>", \
						 "<span class='notice'>You kick the display case.</span>")
		src.health -= 2
		healthcheck()
		return


/obj/structure/displaycase/captain
	alert = 1

/obj/structure/displaycase/captain/New()
	..()
	showpiece = new /obj/item/weapon/gun/energy/laser/captain (src)
	update_icon()

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."

/obj/structure/displaycase/labcage/New()
	..()
	var/obj/item/clothing/mask/facehugger/A = new /obj/item/clothing/mask/facehugger(src)
	A.sterile = 1
	A.name = "Lamarr"
	showpiece = A
	update_icon()

