# viper.tcl v0.1

bind evnt - init-server evnt:init_server

proc evnt:init_server {type} {
  global botnick
  putquick "MODE $botnick +i-ws"
}
