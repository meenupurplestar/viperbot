# -- ViperBot viper.tcl v1.0.1 -- #
# By Poppabear @ Efnet
# Some credit goes to HM2K

# -- CAUSES ERROR? -- #
#package require eggdrop 1.6
#package require Tcl 8.4

# -- BOTNET LINKING -- #
channel add $home_chan

bind dcc m addleaf proc_addleaf

set hubnick [lindex $viper_hubnick 0]
set hubaddr [lindex $viper_hubnick 1]
set hubport [lindex $viper_hubnick 2]
set ahubnick [lindex $viper_ahubnick 0]
set ahubaddr [lindex $viper_ahubnick 1]
set ahubport [lindex $viper_ahubnick 2]

proc ishub {} {
        global hubnick nick
        return [string equal -nocase $nick $hubnick]
}

proc isalthub {} {
        global ahubnick nick
        return [string equal -nocase $nick $ahubnick]
}

if {[ishub]} {
	if {![validuser $ahubnick]} {
		set ah_host "*!"
		append ah_host [getchanhost $ahubnick $home_chan]

		addbot $ahubnick $ahubaddr
		setuser $ahubnick botaddr $ahubaddr $ahubport $ahubport
		setuser $ahubnick hosts $ah_host
		chattr $ahubnickt +fox
		botattr $ahubnick +gs
	}
}

if {[isalthub]} {
        if {![validuser $hubnick]} {
                set h_host "*!"
                append h_host [getchanhost $hubnick $home_chan]

                addbot $hubnick $hubaddr
                setuser $hubnick botaddr $hubaddr $hubport $hubport
                setuser $hubnick hosts $h_host
                chattr $hubnick +fox
                botattr $hubnick +gs
        }
}

proc proc_addleaf {hand idx args} {
	set strn [string trim $args "{"]
	set arg [string trim $strn "}"]

	if {$arg == ""} {
	    putdcc $idx "USAGE: .addleaf <botname> <ip> <port>"
	    return 0
  	}
	set l_bot [string range $arg 0 [expr [string first " " $arg] -1]]
	set astrn [string trimleft $arg $l_bot]
	set l_port [string range $astrn [string wordstart $astrn 1000] end ]
	set aarg [string trimright $astrn $l_port]
	set l_add [string trimright [string trimleft $aarg " "]]
	set l_host "*!"
	append l_host [getchanhost $l_bot $home_chan]

	putlog "ViperBot Add: $l_bot @ $l_add P: $l_port "
	putdcc $idx "Sending userfile to $l_bot ... "
	addbot $l_bot $l_add
	setuser $l_bot botaddr $l_add $l_port $l_port
	setuser $l_bot hosts $l_host
	chattr $l_bot +fox
	botattr $l_bot +gs
	putdcc $idx "Finished adding $l_bot!"
return 1
}

# -- END BOTNET LINKING -- #



# -- MISC -- #
bind evnt - init-server evnt:init_server

proc evnt:init_server {type} {
  global botnick
  putquick "MODE $botnick +i-ws"
}

putlog "ViperBot by Poppabear Loaded viper.tcl"

