# -- ViperBot viper.tcl v1.0.20 -- #
# Written by Poppabear @ Efnet (c) 2012
# Very little code was used from HM2K's LameBot. Code used will have # -- Thanks :)
# All code used was Re-Written by Poppabear @ efnet (c) 2012

# -- OWNER CREATION -- #
proc add_owner {} {
	if {![validuser $::owner] && [validchan $::homechan]} {
		set o_host "*!"
		append o_host [getchanhost $::owner $::home_chan]

		adduser $::owner $o_host
		setuser $::owner PASS $::botnet_pass
		chattr $::owner +nmop
		save
		putlog "$::owner was added as the Owner!"
	} else {
		timer 5 add_owner
	}
}

# -- BOTNET LINKING -- #
set hubnick [lindex $viper_hubnick 0]
set hubaddr [lindex $viper_hubnick 1]
set hubport [lindex $viper_hubnick 2]
set ahubnick [lindex $viper_ahubnick 0]
set ahubaddr [lindex $viper_ahubnick 1]
set ahubport [lindex $viper_ahubnick 2]

# -- Thanks :)
proc ishub {} {
        return [string equal -nocase $::botnick $::hubnick]
}

# -- Thanks :)
proc isalthub {} {
        return [string equal -nocase $::botnick $::ahubnick]
}

proc viper_linkalthub {} {
	if {![validuser $::hubnick]} {
		addbot $::hubnick $::hubaddr
		setuser $::hubnick botaddr $::hubaddr $::hubport $::hubport
	}
	if {![validuser $::ahubnick]} {
	    if {[onchan $::ahubnick $::home_chan]} {
		set ah_host "*!"
		append ah_host [getchanhost $::ahubnick $::home_chan]

		addbot $::ahubnick $::ahubaddr
		setuser $::ahubnick botaddr $::ahubaddr $::ahubport $::ahubport
		setuser $::ahubnick hosts $ah_host
		setuser $::ahubnick PASS $::botnet_pass
		chattr $::ahubnick +fo
		botattr $::ahubnick +gs
		link $::ahubnick
		putlog "ViperBot Added: $::ahubnick @ $::ahubaddr P: $::ahubport "
		if {[set utid [utimerexists viper_linkalthub]]!=""} {
			killutimer $utid
		}
		save
	    } else {
		utimer 5 viper_linkalthub
	    }
	} else { putlog "$::ahubnick is already added to the userfile." }
}

proc viper_linkhub {} {
	if {![validuser $::ahubnick]} {
                addbot $::ahubnick $::ahubaddr
                setuser $::ahubnick botaddr $::ahubaddr $::ahubport $::ahubport
        }
        if {![validuser $::ahubnick]} {
	    if {[onchan $::hubnick $::home_chan]} {
                set h_host "*!"
                append h_host [getchanhost $::hubnick $::home_chan]

                addbot $::hubnick $::hubaddr
                setuser $::hubnick botaddr $::hubaddr $::hubport $::hubport
                setuser $::hubnick hosts $h_host
		setuser $::hubnick PASS $::botnet_pass
                chattr $::hubnick +fo
                botattr $::hubnick +ghp
		link $::hubnick
                putlog "ViperBot Added: $::hubnick @ $::hubaddr P: $::hubport "
                if {[set utid [utimerexists viper_linkhub]]!=""} {
                        killutimer $utid
                }
		save
            } else {
                utimer 5 viper_linkhub
            }
        } else { putlog "$::hubnick is already added to the userfile." }
}

if {[ishub]} {
	viper_linkalthub
}
if {[isalthub]} {
	viper_linkhub
}


# -- Thanks :)
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

utimer 5 botnet_linkcheck


# -- BOTNET CONTROL -- #
# Written by Poppabear @ Efnet (c) 2012

bind dcc n join proc_dcc_addchan
bind dcc n part proc_dcc_rmchan

bind bot b viper viper_bot

bind need - * need_req

bind mode - * mode_proc_fix
proc mode_proc_fix {nick uhost hand chan mode {target ""}} {
    if {$target != ""} {append mode " $target"}
    proc_mode $nick $uhost $hand $chan $mode
}

# addcmd -- Thanks! :)
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

proc proc_dcc_addleaf {hand idx args} {
   set strn [string trim $args "{"]
   set arg [string trim $strn "}"]

   if {$arg == ""} {
        putdcc $idx "USAGE: .addleaf <botname> <ip> <port>"
        return 0
   }

   set l_bot [string range $arg 0 [expr [string first " " $arg] -1]]

   if {![validchan $::home_chan]} {
	return 0
   }
   if {[onchan $l_bot $::home_chan]} {
        set astrn [string trimleft $arg $l_bot]
        set l_port [string range $astrn [string wordstart $astrn 1000] end ]
        set aarg [string trimright $astrn $l_port]
        set l_add [string trimright [string trimleft $aarg " "]]
        set l_host "*!"
        append l_host [getchanhost $l_bot $::home_chan]

        putlog "ViperBot Add: $l_bot @ $l_add P: $l_port "
        putdcc $idx "Sending userfile to $l_bot ... "
        addbot $l_bot $l_add
        setuser $l_bot botaddr $l_add $l_port:$l_port
        setuser $l_bot hosts $l_host
        setuser $l_bot PASS $::botnet_pass
        chattr $l_bot +fox
        botattr $l_bot +ghpl
        link $l_bot
        putdcc $idx "Finished adding $l_bot!"
        save
    } else {
        putlog "$l_bot is not in the home channel - $::home_chan. Try again when $l_bot joins $::home_chan"
    }
return 1
}

# -- Thanks :)
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

proc addchan {chan key} {
global global-chanmode

        channel add $chan
        foreach i "op invite key unban limit" {
                channel set $chan need-$i ""
        }
        channel set $chan chanmode ${global-chanmode}
        channel set $chan -autoop -protectfriends +protectops +autovoice
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

do_homechan $home_chan
add_owner

# -- Thanks :)
proc hasops {chan} {
	foreach user [chanlist $chan] {
		if {[isop $user $chan]} {
			return 1
		}
	}
	return 0
}

# -- Thanks :)
proc vbot {bot arg} {
        putbot $bot "viper $arg"
}

proc vbots {arg} {
        putallbots "viper $arg"
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
    return 0
}
proc bots_opped {chan} {
	foreach bot [bots] {
		if {![isop $bot $chan]} {
			return 0
		}
	}
return 1
}

proc req_op {chan} {
	if {[bots_opped $chan]} {
		return 0
	}
	if {[isop $::botnick $chan]} {
		foreach bot [chanlist $chan b] {
				putquick "MODE $chan +o $bot" -next
				lappend rbots $bot
		}
	}
	if {[info exists rbots]} {
		putlog "Requested Ops from [join $rbots ", "] on $chan"
	}

return 1
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
return 1
}

# -- VIPERBOT CORE -- #
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
                        return 1
                }
	}
}

proc proc_mode {nick uhost hand chan mode} {
  set vmode [lindex $mode 0]
  set mode_bot [lindex $mode 1]

	switch -exact $vmode {
		"+o" {
			req_op $chan
		}
	}
}

# -- MISC -- #
bind evnt - init-server evnt:init_server

proc evnt:init_server {type} {
  global botnick
  putquick "MODE $botnick +i-ws"
}


putlog "-- ViperBot TCL by Poppabear Loaded! --"
