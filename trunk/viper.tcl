# -- ViperBot viper.tcl v1.0.20 -- #
# Written by Poppabear @ Efnet (c) 2012
# Very little code was used from HM2K's LameBot.
# ALL code used was Re-Written by Poppabear @ efnet (c) 2012

if {![info exists loaded]} {
	set loaded 0
}

proc ishub {} {
        return [string equal -nocase $::botnick $::hubnick]
}

proc isalthub {} {
        return [string equal -nocase $::botnick $::ahubnick]
}

proc isowner {arg} {
	if {[string equal -nocase $i $arg]} {
		return 1
	}
return 0
}

proc notowner {idx} {
        if {![valididx $idx]} {
		return 0
	}
        putidx $idx "You are not authorized."
}

# -- OWNER CREATION -- #
bind msg - auth auth_owner

proc auth_msg {} {
	if {![validuser $::owner] && [validchan $::home_chan] && [onchan $::owner $::home_chan] && [ishub]} {
                putserv "NOTICE $::owner :Hello $::owner, Please /msg $::hubnick AUTH <password>"
	}
}

proc auth_owner {nick host hand arg} {
	set pass [lindex $arg 0]
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
set hubnick [lindex $viper_hubnick 0]
set hubaddr [lindex $viper_hubnick 1]
set hubport [lindex $viper_hubnick 2]
set ahubnick [lindex $viper_ahubnick 0]
set ahubaddr [lindex $viper_ahubnick 1]
set ahubport [lindex $viper_ahubnick 2]

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

proc matchbotattr {bot flags} {
        foreach flag [split $flags ""] {
                if {[lsearch -exact [split [botattr $bot] ""] $flag] < 0} then {
                        return 0
                }
        }
        return 1
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



# -- BOTNET CONTROL -- #
bind dcc n join proc_dcc_addchan
bind dcc n part proc_dcc_rmchan

bind need - * need_req

bind bot b viper viper_bot

bind mode - * mode_proc_fix
proc mode_proc_fix {nick uhost hand chan mode {target ""}} {
    if {$target != ""} {append mode " $target"}
    proc_mode $nick $uhost $hand $chan $mode
}

proc addcmd {type flag cmd proc usage desc} {
global helpindex
        if {[lindex $flag 1] != ""} {
		set flag [join flag |]
	}
    bind $type $flag $cmd $proc
    lappend helpindex "\"$type\" \"$flag\" \"$cmd\" \"$usage\" \"$desc\""
}

addcmd dcc n addleaf proc_dcc_addleaf {<botname> <ip> <port>} {Add a leaf bot to the Botnet}
addcmd dcc n addchan proc_dcc_addchan {<#channel> [key]} {Botnet join a #channel with the key, if there is one}
addcmd dcc n rmchan proc_dcc_rmchan {<#channel>} {Botnet leave #channel}
addcmd dcc n mrehash proc_dcc_mrehash {} {Botnet rehash (all bots)}

proc proc_dcc_addleaf {hand idx args} {
        if {![isowner $hand]} { notowner $idx ; return 0 }
        set leafnick [lindex $arg 0]
        set leafhost [lindex $arg 1]
        set leafport [lindex $arg 2]
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
	        addbot $leafnick $leafhost:$leafport
	        setuser $leafnick PASS $::botnet_pass
		setuser $leafnick HOST $hosts
	        chattr $leafnick +of
	        botattr $leafnick +gs
        	link $leafnick
	        return 1
	}
}

proc proc_dcc_addchan {hand idx arg} {
  set chan [lindex $arg 0]
  set key [lindex $arg 1]

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
  vbots "join $chan $key"
  addchan $chan $key
 return 0
}

proc proc_dcc_rmchan {hand idx arg} {
   if {$arg == ""} {
        putdcc $idx "USAGE: .rmchan <#channel>"
        return 0
   }
   set chan [lindex $arg 0]
   vbots "part $chan"
   return 0
}

proc proc_dcc_mrehash {hand idx command} {
        rehash
        putidx $idx "Mass rehashing all bots"
        vbots "mrehash"
}

proc addchan {chan key} {
global global-chanmode global-chanset

        channel add $chan
        foreach i "op invite key unban limit" {
                channel set $chan need-$i ""
        }
        channel set $chan chanmode ${global-chanmode}
	channel set $chan ${global-chanset}
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

do_homechan $home_chan
timer 1 "do_hubs_hosts"
timer 1 "auth_msg"

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
		if {[islinked $nick]} {
			set hand [nick2hand $::botnick $chan]
			vbot $nick "givebot_ops $hand $chan"
			putlog "$hand has requested ops from $nick"
                }
	} else {
		# -- NEED TO FIX -- #
		foreach bot [chanlist $chan b] {
			#if {[isop $bot $chan]} { set opnick $bot }
	                set hand [nick2hand $bot $chan]
        	        if {[matchattr $hand o|o $chan] && ![matchattr $hand d|d $chan] && [isop $bot $chan] && ![onchansplit $bot $chan] && [islinked $hand]} {
				putquick "MODE $chan +o $hand" -next
                	}
        	}

	}
}

proc req_invite {chan} {
    foreach bot [bots] {
	if {[matchattr $bot b] && [matchattr $bot o|o $chan]} {
		putquick "INVITE $bot $chan"
                lappend rbots $bot
        }
    }
    if {[info exists rbots]} {
        putlog "Requested In from [join $rbots ", "] on $chan"
    } else {
        putlog "No bots to ask for in on $chan"
    }
}

# -- VIPERBOT CORE -- #
proc viper_bot {bot cmd arg} {
	set cmd [string tolower [lindex [set varg [split $arg]] 0]]
        set varg [split [set arg [join [lrange $varg 1 end]]]]

	switch -exact -- $cmd {
                "join" {
                        set chan [lindex $varg 0]
                        set key [lindex $varg 1]
                        addchan $chan $key
                        return 1
                }
                "part" {
                        set chan [lindex $varg 0]
                        channel remove $chan
                        return 1
                }
		"mrehash" {
			rehash
			return 1
		}
		"checkbot_modes" {
			set mnick [lindex $varg 0]
			set chan [lindex $varg 1]
			set vmode [lindex $varg 2]

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
			set hand [lindex $varg 0]
			set chan [lindex $varg 1]
			putlog "Giving $hand Ops ..."
			putquick "MODE $chan +o $hand" -next
		}
	}
}

proc proc_mode {nick uhost hand chan mode} {
  set vmode [lindex $mode 0]
  set mnick [lindex $mode 1]

	switch -exact $vmode {
		"+o" {
			if {[isbotnick $mnick]} {
				putlog "Checking if bots need ops ..."
				vbots "checkbot_modes $mnick $chan $vmode"
			return 0
			}
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
