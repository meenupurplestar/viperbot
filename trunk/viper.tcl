# -- ViperBot viper.tcl v1.0.36a -- #
# Written by Poppabear @ Efnet (c) 2012
# Very little code was used from HM2K's LameBot.
# ALL code used was Re-Written by Poppabear @ efnet (c) 2012

#########################################################################
#									#
#	DO NOT EDIT THIS FILE UNLESS YOU KNOW WHAT YOU ARE DOING!!	#
#									#
#########################################################################


# -- COMMAN PROCS -- #
if {![info exists loaded]} {
	set loaded 0
}

bind mode - * mode_proc_fix
proc mode_proc_fix {nick uhost hand chan mode {target ""}} {
    if {$target != ""} {append mode " $target"}
    proc_mode $nick $uhost $hand $chan $mode
}

proc ishub {} {
        return [string equal -nocase $::botnick $::hubnick]
}

proc isalthub {} {
        return [string equal -nocase $::botnick $::ahubnick]
}

proc isowner {arg} {
        foreach i [split [join $::owner ""] ,] {
                if {[string equal -nocase $i $arg]} {return 1}
        }
        return 0
}

proc notowner {idx} {
        if {![valididx $idx]} {return 0}
        putidx $idx "You are not authorized."
}

proc matchbotattr {bot flags} {
        foreach flag [split $flags ""] {
                if {[lsearch -exact [split [botattr $bot] ""] $flag] < 0} then {
                        return 0
                }
        }
        return 1
}

proc hasops {chan} {
        foreach user [chanlist $chan] {
                if {[isop $user $chan]} {
                        return 1
                }
        }
return 0
}

proc vbot {bot arg} {
        putbot $bot "viper $arg"
}

proc vbots {arg} {
        putallbots "viper $arg"
}

proc botlist { } {
        set these [list]
        foreach user [userlist] {
                if {[matchattr $user b]} {
                        lappend these $user
                }
        }
return $these
}

proc addchan {chan key} {
global global-chanmode global-chanset

        channel add $chan
        foreach i "op invite key unban limit" {
                channel set $chan need-$i ""
        }
        channel set $chan chanmode ${global-chanmode}
        foreach cmode ${global-chanset} {channel set $chan $cmode}
        if {$key != ""} {
                        putserv "JOIN $chan $key"
        }
        save
return 1
}

proc do_homechan {chan} {
        if {![validchan $chan]} {
                addchan $chan ""
                save
        }
}

# -- OWNER CREATION -- #
bind msg - auth auth_owner

proc auth_msg {} {
	if {![validuser $::owner] && [validchan $::home_chan] && [onchan $::owner $::home_chan] && [ishub]} {
                putserv "NOTICE $::owner :Hello $::owner, Please /msg $::hubnick AUTH <password>"
	}
}

proc auth_owner {nick host hand arg} {
	foreach {pass} [split $arg] {break}
	if {![string equal $pass $::botnet_pass] || ![string equal $nick $::owner]} {
		return 0
	} elseif {![validuser $::owner] && [validchan $::home_chan] && [onchan $::owner $::home_chan] && [ishub]} {
		putserv "NOTICE $::owner :Password ACCEPTED!"
		add_owner $::owner
	}
}

proc add_owner {nick} {
	if {![validuser $nick]} {
		set o_host "*!"
		append o_host [getchanhost $nick $::home_chan]

		adduser $nick $o_host
		setuser $nick PASS $::botnet_pass
		chattr $nick +nmop
		save
		putlog "$nick was added as the Owner!"
	} else {
		putlog "$nick is already a valid user in my userfile"
	}
}

# -- BOTNET LINKING -- #
foreach {hubnick hubaddr hubport} [split $viper_hubnick] {break}
foreach {ahubnick ahubaddr ahubport} [split $viper_ahubnick] {break}

proc botnet_check {} {
	if {[ishub]} {
		if {![validuser $::hubnick]} {
			addbot $::hubnick $::hubaddr:$::hubport
		}
		if {![validuser $::ahubnick]} {
			addbot $::ahubnick $::ahubaddr:$::ahubport
		}
		if {[matchattr $::hubnick d] || ![matchattr $::hubnick o] || ![matchattr $::hubnick f]} {
			chattr $::hubnick -d+of
		}

		if {[matchattr $::ahubnick d] || ![matchattr $::ahubnick o] || ![matchattr $::ahubnick f]} {
			chattr $::ahubnick -d+fo
		}
		if {[matchbotattr $::ahubnick l] || ![matchbotattr $::ahubnick gs]} {
			botattr $::ahubnick +gs-l
		}
		if {![passwdok $::hubnick $::botnet_pass]} {
			setuser $::hubnick PASS $::botnet_pass
		}
		if {![passwdok $::ahubnick $::botnet_pass]} {
			setuser $::ahubnick PASS $::botnet_pass
		}
		foreach b [userlist b] {
			if {$b != $::hubnick && $b != $::ahubnick} {
				if {[matchbotattr $b l] || ![matchbotattr $b gs]} {
					botattr $b +gs-l
				}
				if {[matchattr $b d] || ![matchattr $b o] || ![matchattr $b f]} {
					chattr $b -d+fo
				}
				if {![passwdok $b $::botnet_pass]} {
					setuser $b PASS $::botnet_pass
				}
			}
		}
	} elseif {[isalthub]} {
		if {![validuser $::ahubnick]} {
			addbot $::ahubnick $::ahubaddr:$::ahubport
		}
		if {![validuser $::hubnick]} {
			addbot $::hubnick $::hubaddr:$::hubport
		}
		if {![matchbotattr $::hubnick ghp]} {
			botattr $::hubnick +ghp
		}
		if {[matchattr $::hubnick d] || ![matchattr $::hubnick o] || ![matchattr $::hubnick f]} {
			chattr $::hubnick -d+of
		}
		if {![passwdok $::hubnick $::botnet_pass]} {
			setuser $::hubnick PASS $::botnet_pass
		}
		foreach b [userlist b] {
			if {$b != $::ahubnick && $b != $::hubnick} {
				if {[matchbotattr $b l]} {
					botattr $b -l
				}
				if {![passwdok $b $::botnet_pass]} {
					setuser $b PASS $::botnet_pass
				}
			}
		}
	} else {
		if {![validuser $::hubnick]} {
			addbot $::hubnick $::hubaddr:$::hubport
		}
		if {![matchbotattr $::hubnick ghp]} {
			botattr $::hubnick +ghp
		}
		if {[matchattr $::hubnick d] || ![matchattr $::hubnick o] || ![matchattr $::hubnick f]} {
			chattr $::hubnick -d+of
		}
		if {![validuser $::ahubnick]} {
			addbot $::ahubnick $::ahubaddr:$::ahubport
		}
		if {![matchbotattr $::ahubnick a]} {
			botattr $::ahubnick +a
		}

		if {[matchattr $::ahubnick d] || ![matchattr $::ahubnick o] || ![matchattr $::ahubnick f]} {chattr $::ahubnick -d+fo}
		if {![passwdok $::hubnick $::botnet_pass]} {
			setuser $::hubnick PASS $::botnet_pass
		}
		if {![passwdok $::ahubnick $::botnet_pass]} {
			setuser $::ahubnick PASS $::botnet_pass
		}
	}
	save
}

proc do_hubs_hosts {} {
        if {[ishub]} {
                if {![onchan $::botnick $::home_chan]} {
                        utimer 5 do_hubs_hosts
                        return
                }
                if {![validuser $::hubnick] || [getuser $::hubnick HOSTS] != ""} {
                        return
                } else {
                        set hosts "*!*"
                        set full_host [getchanhost $::botnick $::home_chan]
                        set host_strip [lindex [split $full_host "~"] 1]
                        if {$host_strip != ""} {
                                append hosts $host_strip
                        } else {
                                append hosts $full_host
                        }
                        setuser $::hubnick HOST $hosts
                        putlog "$hosts was added to $::hubnick"
                }

        } elseif {[isalthub]} {
                if {![onchan $::botnick $::home_chan]} {
                        utimer 5 do_hubs_hosts
                        return
                }
                if {![validuser $::ahubnick] || [getuser $::ahubnick HOSTS] != ""} {
                        return
                } else {
                        set hosts "*!*"
                        set full_host [getchanhost $::botnick $::home_chan]
                        set host_strip [lindex [split $full_host "~"] 1]
                        if {$host_strip != ""} {
                                append hosts $host_strip
                        } else {
                                append hosts $full_host
                        }
                        setuser $::ahubnick HOST $hosts
                        putlog "$hosts was added to $::ahubnick"
                }

        }
}

proc botnet_linkcheck {} {
        if {[ishub]} {
                foreach b [userlist b] {
                        if {![islinked $b]} {
				link $b
			}
                }
        } elseif {[bots] == ""} {
                link $::hubnick
        }
}

if {!$loaded} {
	utimer 5 "botnet_check"
}
if {!$loaded} {
        utimer 5 "botnet_linkcheck"
}



# -- VIPERBOT COMMANDS -- #
# all unbind(s) where updated in the help files with new commands and desc!
unbind dcc - +bot *dcc:+bot
unbind dcc - -bot *dcc:-bot
unbind dcc - +chan *dcc:+chan
unbind dcc - -chan *dcc:-chan

bind dcc n join proc_dcc_addchan
bind dcc n part proc_dcc_rmchan

bind need - * need_req
bind bot b viper viper_bot

bind dcc n addleaf proc_dcc_addleaf
bind dcc n rmleaf proc_dcc_rmleaf
bind dcc n addchan proc_dcc_addchan
bind dcc n rmchan proc_dcc_rmchan
bind dcc n mrehash proc_dcc_mrehash

proc proc_dcc_addleaf {hand idx arg} {
        if {![isowner $hand]} { putidx $idx "You must be a owner to use .addleaf" ; return 0 }
	foreach {leafnick leafip leafport} [split $arg] {break}
        if {$leafport == ""} {
                putidx $idx "USAGE: .addleaf <botnick> <IPv4> <port>"
                return 0
        }
        if {![ishub]} {
                putidx $idx "This bot is not the hub, Please .addleaf on $::hubnick"
                return 0
        }
        if {[validuser $leafnick]} {
		putidx $idx "$leafnick is already in my userfile!"
                return 0
        }
	if {![validchan $::home_chan] || ![onchan $leafnick $::home_chan]} {
		putidx $idx "$leafnick is NOT on $::home_chan. Once $leafnick joins $::home_chan .addleaf again!"
		return 0
	} else {
		set hosts "*!*"
		set full_host [getchanhost $leafnick $::home_chan]
		set host_strip [lindex [split $full_host "~"] 1]
		if {$host_strip	!= ""} {
			append hosts $host_strip
		} else {
			append hosts $full_host
		}
	        addbot $leafnick $leafip:$leafport
	        setuser $leafnick PASS $::botnet_pass
		setuser $leafnick HOSTS $hosts
	        chattr $leafnick +of
	        botattr $leafnick +gs
        	link $leafnick
	        return 1
	}
}

proc proc_dcc_rmleaf {hand idx arg} {
foreach {leafnick} [split $arg] {break}
	if {$leafnick == ""} {
        	putidx $idx "USAGE: .rmleaf <botnick>"
        	return 0
	}
	if {[unlink $leafnick] && [deluser $leafnick]} {
		putlog "$leafnick has been unlinked and removed from the userfile."
		return 1
	}

return 0
}

proc proc_dcc_addchan {hand idx arg} {
foreach {chan key} [split $arg] {break}

  if {$chan == ""} {
        putidx $idx "USAGE: .addchan <#channel> \[key\]"
        return 0
  }
  if {![string match *[string index $chan 0]* #&]} {
        set chan "#$chan"
  }
  if {[validchan $chan]} {
        putidx $idx "I'm already on $chan"
        return 0
  }
  putidx $idx "Joining $chan"
  addchan $chan $key
  vbots "join $chan $key"
 return 0
}

proc proc_dcc_rmchan {hand idx arg} {
   if {$arg == ""} {
        putdcc $idx "USAGE: .rmchan <#channel>"
        return 0
   }
   foreach {chan} [split $arg] {break}
   putidx $idx "Parting $chan"
   channel remove $chan
   vbots "part $chan"
   return 0
}

proc proc_dcc_mrehash {hand idx command} {
        rehash
        putidx $idx "Mass rehashing all bots"
        vbots "mrehash"
}

do_homechan $home_chan
timer 1 "do_hubs_hosts"
timer 1 "auth_msg"


# -- BOT REQUESTS -- #
proc need_req {chan need} {
    switch -exact $need {
	"op" {
	   req_op $chan
	}
	"invite" {
	   req_invite $chan
	}
	"unban" {
	   req_unban $chan
	}
	"limit" {
	   req_limit $chan
	}
	"key" {
	   req_key $chan
	}
    }
}

proc req_op {chan {nick ""}} {
	if {[string length $nick]} {
		if {[islinked $nick] && ![isop $::botnick $chan]} {
			set hand [nick2hand $::botnick $chan]
			vbot $nick "givebot_ops $hand $chan"
			putlog "$hand has requested ops from $nick"
                }
	} else {
		foreach bot [chanlist $chan b] {
			set hand [nick2hand $bot $chan]
        	        if {[matchattr $hand o|o $chan] && ![matchattr $hand d|d $chan] && [isop $bot $chan] && ![onchansplit $bot $chan] && [islinked $hand]} {
				vbot $bot "givebot_ops $::botnick $chan"
                	}
        	}

	}
}

proc req_invite {chan} {
    set hand [lindex [split $::botname !] 0]
    foreach bot [bots] {
		putlog "Requested In from $bot on $chan"
    		vbot $bot "req_invite $hand $::botnick $chan"
    }
}

proc req_unban {chan} {
	set hand [lindex [split $::botname !] 0]
	if {![onchan $botnick $chan]} {
		regsub -all " " [bots] ", " botlist
		putlog "Requesting unban from $chan (querying: $botlist)"
		vbots "req_unban $chan $hand $::botname"
	}
}

proc req_limit {chan} {
	if {![onchan $botnick $chan]} {
		regsub -all " " [bots] ", " botlist
		putlog "Requesting limit increase for $chan (querying: $botlist)"
	        vbots "req_limit $chan"
	}
}

proc req_key {chan} {
	set hand [lindex [split $::botname !] 0]
	putlog "Requesting key for $chan"
	vbots "req_key $chan $hand"
}

# -- MODE CHANGE HANDLING -- #
proc proc_mode {nick uhost hand chan mode} {
  foreach {vmode mnick} [split $mode] {break}

        switch -exact $vmode {
                "+o" {
                        if {[isbotnick $mnick]} {
                                putlog "Checking if bots need ops ..."
                                vbots "checkbot_modes $mnick $chan $vmode"
                        return 0
                        }
                }
		"-o" {

		}
        }
}


# -- VIPERBOT -- #
proc viper_bot {bot cmd arg} {
        set cmd [string tolower [lindex [set larg [split $arg]] 0]]
        set larg [split [set arg [join [lrange $larg 1 end]]]]

	switch -exact -- $cmd {
                "join" {
			set chan [lindex $larg 0]
			set key [lindex $larg 1]
                        addchan $chan $key
                        return 1
                }
                "part" {
			set chan [lindex $larg 0]
                        channel remove $chan
			save
                        return 1
                }
		"req_invite" {
			set hand [lindex $larg 0]
			set anick [lindex $larg 1]
			set chan [lindex $larg 2]
			if {[botisop $chan]} {
				putlog "Inviting $anick to $chan"
				putquick "INVITE $anick $chan"
				vbot $hand "invited $chan"
			} else {
				putlog "I'm not opped in $chan"
			}
		}
		"invited" {
			set chan [lindex $larg 0]
			putquick "JOIN $chan"
		}
		"req_limit" {
			set chan [lindex $larg 0]
			set curlimit [string range [getchanmode $chan] [expr [string last " " [getchanmode $chan]] + 1] end]
	                if {$curlimit <= [llength [chanlist $chan]]} {
                		set newlimit [expr [llength [chanlist $chan]] + 1]
		                pushmode $chan +l $newlimit
                		putlog "$::botnick Raised limit on $chan"
            		}
		}
	        "req_unban" {
			set chan [lindex $larg 0]
			set hand [lindex $larg 1]
			set host [lindex $larg 2]
            		foreach ban [chanbans $chan] {
                		if {[string match [string tolower [lindex $ban 0]] [string tolower [lindex $host 0]]]} {
                    			pushmode $chan -b [lindex $ban 0]
                    			putlog "$ban has been removed from banlist on $chan"
                    			vbot $hand "unbanned $chan"
                		}
            		}
        	}
		"unbanned" {
			set chan [lindex $larg 0]
			putquick "JOIN $chan"
		}
		"req_key" {
			set chan [lindex $larg 0]
			set hand [lindex $larg 1]
			if {[string match *k* [lindex [getchanmode $chan] 0]]} {
                 		vbot $hand "recd_key $chan [lindex [getchanmode $chan] 1]"
				return
             		}
             		putlog "There is no key for $chan"
		}
		"recd_key" {
			set chan [lindex $larg 0]
			set key [lindex $larg 1]
                        putquick "JOIN $chan $key"
		}
		"mrehash" {
			rehash
		}
		"checkbot_modes" {
			set mnick [lindex $larg 0]
                        set chan [lindex $larg 1]
                        set vmode [lindex $larg 2]

			switch -exact $vmode {
				"+o" {
					if {![botisop $chan]} {
							req_op $chan $mnick
					}

				}
				"-o" {

				}
			}

		}
		"req_op" {

		}
		"givebot_ops" {
			set hand [lindex $larg 0]
                        set chan [lindex $larg 1]

			putlog "Giving $hand Ops ..."
			putquick "MODE $chan +o $hand" -next
		}
	}
}

# -- MISC -- #
bind evnt - init-server evnt:init_server

proc evnt:init_server {type} {
  global botnick
  putquick "MODE $botnick +i-ws"
}


set loaded 1
putlog "-- ViperBot TCL by Poppabear Loaded! --"

