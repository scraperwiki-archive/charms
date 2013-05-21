local json = require "json";
local file, _err = io.open("/home/"..ngx.var.box_name.."/box.json", "r");

if not file then
  file, _err = io.open("/home/"..ngx.var.box_name.."/scraperwiki.json", "r");
end

if file then
  _success, sw_json = pcall(function() return json.decode(file:read(102400)) end);
  file:close();
  if sw_json and sw_json.publish_token then
    if ngx.var.t == sw_json.publish_token then
      return ngx.exit(ngx.OK);
    else
      return ngx.exit(ngx.HTTP_FORBIDDEN);
    end
  end
end

if string.len(ngx.var.t) > 0 then
  return ngx.exit(ngx.HTTP_NOT_FOUND);
else
  return ngx.exit(ngx.OK);
end



