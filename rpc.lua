local rpc = {}


function rpc.ssh(host, command, input, stdout_callback)
  -- SSH to a machine and run the command. The third argument is passed to
  -- stdin, and can be omitted.
  -- Optioanlly, you can pass a callback to receive the contents of stdout
  -- (stderr is always logged to the console for debug purposes).
  local t = hs.task.new("/usr/bin/ssh",
    function (code, stdout, stderr)
      local l = hs.logger.new("ssh")
      l.setLogLevel("info")
      l.i("'ssh " .. host .. " " .. command .. "' Exited with code: " .. code)
      if stdout ~= "" then
        if stdout_callback then
          stdout_callback(stdout:gsub("^%s*(.-)%s*$", "%1"))
        else
          l.i("Stdout:" .. stdout)
        end
      end
      if stderr ~= "" then l.i("Stderr:" .. stderr) end
    end,
    {host, command})
  t:setInput(input)
  t:start()
end

function rpc.ssh_rpc(host, code, stdout_callback)
  -- Run hammerspoon code on the specified machine using ssh and the hs command
  rpc.ssh(host, "/opt/homebrew/bin/hs -q -s", code, stdout_callback)
end

function rpc.run_on_machine(machine, code, stdout_callback)
  -- Run hammerspoon code on the desired machine, using rpc if necessary
  machine_name = config.machines[machine]
  if hs.host.localizedName() == machine_name then
    -- We are on the desired machine, just run the code directly
    output = load(code)()
    if stdout_callback then
      stdout_callback(output)
    end
  else
    -- We need to connect to the remote machine first, then make an ipc call
    rpc.ssh_rpc(machine_name .. ".local", code, stdout_callback)
  end
end

-- This sets up a default remote port so the hs command line tool can work
require('hs.ipc')

-- Install the hs command line
hs.ipc.cliInstall('/opt/homebrew')

return rpc
