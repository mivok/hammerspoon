local rpc = {}


function rpc.ssh(host, command, input)
  -- SSH to a machine and run the command. The third argument is passed to
  -- stdin, and can be omitted.
  local t = hs.task.new("/usr/bin/ssh",
    function (code, stdout, stderr)
      local l = hs.logger.new("ssh")
      l.setLogLevel("info")
      l.i("'ssh " .. host .. " " .. command .. "' Exited with code: " .. code)
      if stdout ~= "" then l.i("Stdout:" .. stdout) end
      if stderr ~= "" then l.i("Stderr:" .. stderr) end
    end,
    {host, command})
  t:setInput(input)
  t:start()
end

function rpc.ssh_ipc(host, code)
  -- Run hammerspoon code on the specified machine using ssh and the hs command
  rpc.ssh(host, "/opt/homebrew/bin/hs -s", code)
end

function rpc.run_on_machine(machine, code)
  -- Run hammerspoon code on the desired machine, using rpc if necessary
  machine_name = config.machines[machine]
  if hs.host.localizedName() == machine_name then
    -- We are on the desired machine, just run the code directly
    load(code)()
  else
    -- We need to connect to the remote machine first, then make an ipc call
    rpc.ssh_rpc(machine_name .. ".local", code)
  end
end

-- This sets up a default remote port so the hs command line tool can work
require('hs.ipc')

-- Install the hs command line
hs.ipc.cliInstall('/opt/homebrew')

return rpc
