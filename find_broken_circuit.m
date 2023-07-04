function [l,I] = find_broken_circuit(V,x,method)
  % [l,I] = find_broken_circuit(V,x,method)
  %
  % Inputs:
  %   V  #V by dim list of vertices
  %   x  the location of the break given as a fractional index into rows of V
  %   method  one of:
  %     'bisection'  binary search for break
  %     'brute-force'  walk along circuit until break is found
  %     'dynamic-programming'  dynamic programming
  % Outputs:
  %   l  length of trajectory
  %   I  trajectory starting with 1 of sites visited until the break x is
  %     deductively found 
  %

  function flag = test(x,source,sink)
    flag = x>=source && x<sink;
  end
  
  % Tables for dynamic programming
  L = [];
  K = [];

  % Cumulative distances
  C = [];


  % Build O(n²) table of predicted costs
  function [l,cursor] = cost(source,sink)
    assert(source < sink)
    if ~isnan(L(source,sink))
      l = L(source,sink);
      cursor = K(source,sink);
      return
    end

    if sink-source == 1
      l = 0;
      cursor = -1;
    else
      % minimum over all intermediary moves
      l_min = inf;
      cursor_min = -1;
      for cursor = source+1:sink-1
        % Cost of move (100%)
        l = norm(V(cursor,:)-V(source,:));
        % Cost of recursion (proportional to probability)
        Pleft = (C(cursor)-C(source)) / (C(sink)-C(source));
        Pright = 1-Pleft;
        l = l + Pleft * cost(source,cursor);
        l = l + Pright * cost(cursor,sink);
        if l < l_min
          l_min = l;
          cursor_min = cursor;
        end
        l = l_min;
        cursor = cursor_min;
      end

    end

    L(source,sink) = l;
    K(source,sink) = cursor;
  end

  % Ensure that location is a half-integer
  assert(mod(x,1)==0.5)

  switch method
  case 'dynamic-programming'
    L = nan(size(V,1),size(V,1));
    K = nan(size(V,1),size(V,1));
    C = cumsum([0;normrow((diff(V)))]);
    [l_prob,cursor] = cost(1,size(V,1));
    source = 1;
    sink = size(V,1);
    assert(test(x,source,sink));
    l = 0;
    I = [source];
    while true
      cursor = K(source,sink);
      % travel to predicted curosr
      I = [I;cursor];
      l = l + norm(V(cursor,:)-V(source,:));
      if test(x,cursor,sink)
        source = cursor;
      else
        sink = cursor;
      end
      if sink-source == 1
        break
      end
    end
  case 'bisection'
    sink = size(V,1);
    l = 0;
    source = 1;
    cursor = 1;
    is_broken = test(x,source,sink);
    assert(is_broken);
    I = [cursor];
    while true
      if sink-source == 1
        break
      end
      cursor = floor((source+sink)/2);
      I = [I;cursor];
      l = l+norm(V(cursor,:)-V(source,:));
      flag = test(x,cursor,sink);
      if flag
        % break ∈ [cursor,sink]
        source = cursor;
      else
        % break ∈ [source,cursor]
        sink = cursor;
      end
    end
  case 'brute-force'
    sink = size(V,1);
    l = 0;
    source = 1;
    is_broken = test(x,source,sink);
    assert(is_broken);
    I = [source];
    while true
      % walk to next node
      new_source = source + 1;
      I = [I;new_source];
      l = l + norm(V(new_source,:)-V(source,:));
      flag = test(x,new_source,sink);
      if ~flag
        % we walked too far
        sink = new_source;
        break
      end
      source = new_source;
      if sink-source == 1
        break;
      end
    end
  end
  % Double check that the we've narrowed down to a single edge
  assert(sink-source == 1);
  % Double check that the break is on that edge
  assert(test(x,source,sink));
end
