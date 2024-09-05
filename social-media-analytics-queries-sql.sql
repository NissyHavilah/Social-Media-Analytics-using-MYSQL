SELECT * FROM users;
SELECT * FROM photos;
SELECT * FROM videos;
SELECT * FROM post;
SELECT * FROM comments;
SELECT * FROM post_likes;
SELECT * FROM comment_likes;
SELECT * FROM fallows;
SELECT * FROM hashtags;
SELECT * FROM hashtag_follow;
SELECT * FROM post_tags;
SELECT * FROM bookmarks;
SELECT * FROM login;

-- 1. Find the user with the most followers.
SELECT * FROM users;
SELECT * FROM fallows;

SELECT u.user_id, u.username, f.follower_id, COUNT(followee_id) AS number_of_followers
FROM fallows f JOIN users u
ON f.follower_id = u.user_id
GROUP BY f.follower_id, u.username
ORDER BY number_of_followers DESC LIMIT 1;

-- 2. Calculate the average post size by post type (photo or video). -- incomplete
SELECT * FROM post;
SELECT * FROM photos;

SELECT 'Photos' AS post_type,
       AVG(ph.size) AS avg_size
FROM post p
JOIN photos ph ON p.photo_id = ph.photo_id
UNION ALL
SELECT 'Videos' AS post_type,
       AVG(vi.size) AS avg_size
FROM post p
JOIN videos vi ON p.video_id = vi.video_id;

-- 3. List the top 5 posts with the most comments and their user owners.
SELECT * FROM post;
SELECt * FROM comments;

SELECT u.user_id,
       u.username,
       p.post_id,
       COUNT(c.comment_id) AS comments_count
FROM post p
JOIN comments c ON p.post_id = c.post_id
JOIN users u ON p.user_id = u.user_id
GROUP BY u.user_id, u.username, p.post_id
ORDER BY comments_count DESC
LIMIT 5;

-- 4. Calculate the total number of likes on posts by each user.
SELECT * FROM users;
SELECT * FROM post_likes;

SELECT u.username, count(plk.post_id) AS total_likes
FROM users u
LEFT JOIN post_likes plk ON u.user_id = plk.user_id
GROUP BY u.username;

SELECT u.user_id, count(plk.post_id) AS total_likes
FROM users u
LEFT JOIN post_likes plk ON u.user_id = plk.user_id
GROUP BY u.user_id;

-- 5. Create a view to display the total number of comments and likes for each post:
SELECT * FROM post;
SELECT * FROM comments;

CREATE VIEW PostCommentsAndLikes AS
SELECT p.post_id,
       COUNT(c.comment_id) AS total_comments,
       COUNT(pl.user_id) AS total_likes
FROM post p
LEFT JOIN comments c ON p.post_id = c.post_id
LEFT JOIN post_likes pl ON p.post_id = pl.post_id
GROUP BY p.post_id;

-- Select data from the view and order by post_id
SELECT *
FROM PostCommentsAndLikes
ORDER BY post_id;
 
-- 6. List the 10 most popular hashtags along with the number of posts they are used in:
SELECT * FROM hashtags;
SELECt * FROm post_tags;

SELECT h.hashtag_name,
       COUNT(pt.post_id) AS post_count
FROM hashtags h
LEFT JOIN post_tags pt ON h.hashtag_id = pt.hashtag_id
GROUP BY h.hashtag_name
ORDER BY post_count DESC
LIMIT 10;

-- 7. List the users who have liked their own posts:
SELECT * FROM users;
SELECT * FROM post;

SELECT u.username
FROM users u
JOIN post p ON u.user_id = p.user_id
JOIN post_likes pl ON p.post_id = pl.post_id
WHERE u.user_id = pl.user_id;

-- 8. Find users who have not posted any photos or videos:
SELECT * FROM users;
SELECt * FROM post;

SELECT u.username
FROM users u
LEFT JOIN post p ON u.user_id = p.user_id
WHERE p.post_id IS NULL;

-- 9. Find users who have bookmarked the same post that they liked:
SELECT * FROM users;
SELECt * FROM post_likes;

SELECT u.username, b.post_id
FROM users u
JOIN post_likes pl ON u.user_id = pl.user_id
JOIN bookmarks b ON u.user_id = b.user_id
WHERE pl.post_id = b.post_id;

-- 10. Find the users who have commented on the most posts:
SELECT * FROM users;
SELECt * FROM comments;

SELECT u.username,
       COUNT(c.comment_id) AS comments_count
FROM users u
JOIN comments c ON u.user_id = c.user_id
GROUP BY u.username
ORDER BY comments_count DESC
LIMIT 10;

-- 11. Any specific word in comment:
SELECt * FROM comments;

SELECT *
FROM comments
WHERE comment_text LIKE '%good%' OR comment_text LIKE '%beautiful%';

-- 12. Location of User
SELECT * FROM post;

SELECT *
FROM post
WHERE location = 'agra'
   OR location = 'maharashtra'
   OR location = 'west bengal';
   
-- 13. Most Followed Hashtag
SELECT * FROM hashtags;
SELECT * FROM hashtag_follow;

SELECT 
    h.hashtag_name AS 'Hashtags', 
    COUNT(hf.hashtag_id) AS 'Total Follows'
FROM 
    hashtags h
LEFT JOIN 
    hashtag_follow hf ON h.hashtag_id = hf.hashtag_id
GROUP BY 
    h.hashtag_name
ORDER BY 
    COUNT(hf.hashtag_id) DESC
LIMIT 5;

-- 14. Most Used Hashtags
SELECT * FROM hashtags;
SELECT * FROM post_tags;

SELECT 
    h.hashtag_name AS 'Trending Hashtags', 
    COUNT(pt.hashtag_id) AS 'Times Used'
FROM 
    hashtags h
JOIN 
    post_tags pt ON h.hashtag_id = pt.hashtag_id
GROUP BY 
    h.hashtag_name
ORDER BY 
    COUNT(pt.hashtag_id) DESC
LIMIT 10;

-- 15. Most Inactive User
SELECT * FROM users;

SELECT user_id, username AS 'Most Inactive User'
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT user_id
    FROM post
);

-- 16. Most Likes Posts
SELECT * FROM post_likes;

SELECT post_likes.post_id, COUNT(post_likes.user_id) AS like_count
FROM post_likes
GROUP BY post_likes.post_id
ORDER BY like_count DESC;

-- 17. Average post per user
 SELECT * FROM post;

SELECT ROUND(COUNT(post_id) / COUNT(DISTINCT user_id), 2) AS 'Average Post per User'
FROM post;

-- 18. no. of login by per user
SELECT * FROM users;
SELECT * FROM login;

SELECT u.user_id, u.email, u.username, COUNT(l.login_id) AS login_number
FROM users u
LEFT JOIN login l ON u.user_id = l.user_id
GROUP BY u.user_id;

-- 19. User who liked every single post (CHECK FOR BOT)
SELECT * FROM users;
SELECT * FROM post_likes;

SELECT u.username
FROM users u
JOIN post_likes pl ON u.user_id = pl.user_id
GROUP BY u.user_id
HAVING COUNT(DISTINCT pl.post_id) = (SELECT COUNT(*) FROM post);

-- 20. User Never Comment 
SELECT * FROM users;

SELECT user_id, username AS 'User Never Comment'
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT user_id
    FROM comments
);

-- 21. User who commented on every post (CHECK FOR BOT)
SELECT * FROM users;
SELECT * FROM comments;

SELECT u.username
FROM users u
JOIN comments c ON u.user_id = c.user_id
GROUP BY u.user_id
HAVING COUNT(DISTINCT c.post_id) = (SELECT COUNT(*) FROM post);

-- 22. User Not Followed by anyone
SELECT * FROM users;

SELECT user_id, username AS 'User Not Followed by Anyone'
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT followee_id
    FROM follows
);
-- 23. User Not Following Anyone
SELECT * FROM users;
SELECT * FROM fallows;

SELECT user_id, username AS 'User Not Following Anyone'
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT follower_id
    FROM fallows
);

-- 24. Posted more than 5 times
SELECT * FROM post;

SELECT user_id, COUNT(post_id) AS post_count
FROM post
GROUP BY user_id
HAVING post_count > 5
ORDER BY post_count DESC;

-- 25. Followers > 40
SELECT * FROM fallows;

SELECT followee_id, COUNT(follower_id) AS follower_count
FROM fallows
GROUP BY followee_id
HAVING follower_count > 40
ORDER BY follower_count DESC;

-- 26. Longest captions in post
SELECT * FROM post;

SELECT user_id, caption, LENGTH(caption) AS caption_length
FROM post
ORDER BY caption_length DESC
LIMIT 5;











