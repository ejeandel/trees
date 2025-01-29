-- Queue Data structure 

Queue = {}
function Queue.new ()
  return {first = 0, last = -1}
end

function Queue.push (queue, value)
  local last = queue.last + 1
  queue.last = last
  queue[last] = value
end

function Queue.empty(queue)
   return queue.first > queue.last
end

function Queue.pop (queue)
  local first = queue.first
  local value = queue[first]
  queue[first] = nil
  queue.first = first + 1
  return value
end

-- Convert a json tree into a tree 
function process(tree, lvl)
   local name, children  = next(tree)
   if children ~= 0 then
      for i,v in ipairs(children) do
	 process(v, lvl+1 )
      end
   end   
   
   tree.level = lvl
   tree.name = name
   tree.children = children
   tree[name] = nil
   if tree.children ~= 0 then
      local w = 0
      local d = lvl
      for i,v in ipairs(tree.children) do
	 if v.depth > d then
	    d = v.depth
	 end
	 w = w + v.width
      end
      tree.depth = d
      if w == 0 then
	 w = 1
      end
      tree.width = w
   else
      tree.width = 1
      tree.depth = 1      
   end
      tree.dummy = false
end


-- print_html, uses breadth first search 
function html(tree, math)
   queue = Queue.new()
   current_level = 0
   max_level = tree.depth
   Queue.push(queue, tree)
   current_string = ""
   result = ""   
   while not Queue.empty(queue) do
      local t = Queue.pop(queue)
      if t.level > current_level then
         current_string = current_string .. "</tr>"
         result = current_string .. result
         current_string = "<tr>"
         current_level = t.level
      end
     
      if t.dummy then
         current_string = current_string .. "<td></td>"
         if t.level < max_level then
            Queue.push(queue, {dummy =  true, level =  t.level+1})
         end                     
      else
	 td = ""
	 if t.width > 1 then
	   td = td .. " colspan=\"" .. t.width .. "\""
	 end
	 if t.children ~= 0 then
	    td = td .. " style=\"text-align:center;border-top:2px solid\""
	 else
	    td = td .. " style=\"text-align:center\""
	 end
	 	  
	 current_string = current_string .. "<td " .. td .. ">"

         if math then
            current_string = current_string .. "<span class=" ..'"' .. "math inline" .. '"' .. ">" .. "\\("
         end
      
         current_string = current_string .. t.name
         if math then
            current_string = current_string .. "\\)</span>"
         end
         current_string = current_string .. "</td>"
         if t.children ~=0 and #t.children > 0 then
            for i,c in ipairs(t.children) do            
               Queue.push(queue, c)
            end
         else
            if t.level < max_level then
               Queue.push(queue, {dummy= true, level= t.level+1})
            end            
         end
      end
   end
   current_string = current_string .. "</tr>"
   result = current_string .. result .. "</table>"
   return "<table style=\"border-spacing: 10px;border-collapse:separate\">" .. result
end

-- print_tex
-- uses (recursive) depth first search


function tex_dfs(tree)
   s = ""

   if tree.children ~= 0 then    
      for i,c in ipairs(tree.children) do
	 s = s .. tex_dfs(c)
      end
      
      s = s .. "\\infer" .. #tree.children .. "{" .. tree.name .. "}\n"
   else
      s = s .. "\\hypo{"  .. tree.name .. "}\n"
   end
   return s
end

   

function tex(tree)
   return "\\begin{prooftree}\n" .. tex_dfs(tree) .. "\\end{prooftree}\n" 
end



function CodeBlock(el, args)
   if el.classes:find("tree") then      
      tree = pandoc.json.decode(el.text, false)
      process(tree,0)
      if FORMAT == "html" then 
	 return pandoc.RawInline('html', html(tree, true))
      elseif FORMAT == "latex" then 
	 return pandoc.RawInline('tex', tex(tree, true))
      else
	 error("trees not implemented for " .. FORMAT)
      end
   end
   
end

 
