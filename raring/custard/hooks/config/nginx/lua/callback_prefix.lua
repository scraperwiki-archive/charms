if ngx.var["arg_callback"] then
  return ngx.var["arg_callback"].."("
else
  return ""
end
