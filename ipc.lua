local ipc = {}


function ipc.ssh(host, command)
  -- SSH to a machine and run the command
  hs.task.new("/usr/bin/ssh", nil, {host, command}):start()
end

function ipc.ssh_ipc(host, code)
  -- Run hammerspoon code on the specified machine using ssh and the hs command
  ipc.ssh(host, "/opt/homebrew/bin/hs -c '".. code .."'")
end

function ipc.on_machine(machine, code)
  -- Run hammerspoon code on the desired machine, using IPC if necessary
  if hs.host.localizedName() == machine then
    -- We are on the desired machine, just run the code directly
    load(code)()
  else
    -- We need to connect to the remote machine first, make an ipc call
    ipc.ssh_ipc(machine .. ".local", code)
  end
end

function ipc.on_personal(code)
  ipc.on_machine(config.personal_machine, code)
end

function ipc.on_work(code)
  ipc.on_machine(config.work_machine, code)
end

-- This sets up a default remote port so the hs command line tool can work
require('hs.ipc')

-- Install the hs command line
hs.ipc.cliInstall('/opt/homebrew')

return ipc
