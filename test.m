score = Score('images/Spring.jpg');
player = score.getPlayer();

% for i = 1:length(ss)
%     s = ss{i};
%     os = s.labelObjects(s.findObjects());
%     imshow(s.Image);
%     for j = 1:length(os)
%         object = os{j};
%         if length(object.Label) < 2 || ~(strcmp(object.Label(1:2), 'n ') || strcmp(object.Label, 'qrest'))
%             continue
%         end
%         r = rectangle('Position', object.BoundingBox, 'EdgeColor', 'r');
%         n = Note(s, object);
%         n.buildContents();
%         disp(n.Contents);
%         for k = 1:length(n.Contents)
%             disp(n.Contents{k})
%         end
%         delete(r);
%         disp('---------------------------------');
%     end
% end