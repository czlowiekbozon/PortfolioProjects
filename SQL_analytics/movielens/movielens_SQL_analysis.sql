-- HOW MANY MOVIES THE DATABASE CONTAINS
SELECT COUNT(title) AS number_of_title FROM portfolio_movielens.dbo.movies;


-- HOW MANY GENRES OF MOVIES ARE THRILLER (OR OTHER GENRES)	
	-- FIRST WAY

SELECT count(*) AS 'Thriller' FROM portfolio_movielens.dbo.movies
WHERE genres LIKE '%Thriller%';

	--SECOND WAY
SELECT 
	SUM(CASE WHEN genres LIKE '%Thriller%' THEN 1 ELSE 0 END) AS 'Thriller'
FROM portfolio_movielens.dbo.movies;


-- EXTRACT INFORMATION ABOUT REALES YEAR(DON'T WORKING SO WELL BECAUES IN THE COLUMN TITLE THERE IS SOME ADDITIONAL INFROMATION IN BRACKET, NOT ONLY REALESE YEAR)
SELECT SUBSTRING(title,LEN(LEFT(title,CHARINDEX('(', title)+1)),LEN(title) - LEN(LEFT(title,CHARINDEX('(',title))) - LEN(RIGHT(title,CHARINDEX(')',(REVERSE(title)))))) AS year_reales FROM portfolio_movielens.dbo.movies


-- REMOVING COLUMN F4 FROM DBO.RATINGS TABLE
ALTER TABLE portfolio.movielens.dbo.ratings DROP COLUMN F4;


-- PRINT OUT ALL MOVIES WITH HIGHEST AVERAGE RATING
SELECT title, AVG(rating) AS average_rating FROM portfolio_movielens.dbo.movies AS movies
FULL JOIN portfolio_movielens.dbo.ratings AS ratings
ON movies.movieId = ratings.movieId
GROUP BY title
HAVING AVG(rating) = 5
ORDER BY title;


--SORTING MOVIES BY NUMBER OF RATINGS WITH AVG RATING
SELECT title, COUNT(rating) AS number_of_ratings, ROUND(AVG(rating),2) AS avg_rating FROM portfolio_movielens.dbo.movies AS movies
FULL OUTER JOIN portfolio_movielens.dbo.ratings AS ratings
ON movies.movieId = ratings.movieId
GROUP BY title
ORDER BY COUNT(rating) DESC;


-- WHICH USER GIVES THE HIGHEST NUMBER OF RATINGS 
SELECT userId, COUNT(rating) AS number_of_ratings FROM portfolio_movielens.dbo.ratings
GROUP BY userID
ORDER BY COUNT(rating) DESC;


-- WHICH USER HAVE IN OVERALL THE LOWEST AND HIGHEST AVG RATING SCORE
WITH average_rating_per_user AS 
(SELECT userId, AVG(rating) as avg_rating FROM portfolio_movielens.dbo.movies AS movies
FULL JOIN portfolio_movielens.dbo.ratings AS ratings
ON movies.movieId = ratings.movieId
GROUP BY userId)
SELECT userID, avg_rating FROM average_rating_per_user WHERE avg_rating=(SELECT MIN(avg_rating) FROM average_rating_per_user)
UNION
SELECT userID, avg_rating FROM average_rating_per_user WHERE avg_rating=(SELECT MAX(avg_rating) FROM average_rating_per_user);


-- CREATING TEMP TABLE
DROP TABLE IF EXISTS #NumberOfMoviesRatings
CREATE TABLE #NumberOfMoviesRatings
(	
	movie_title NVARCHAR(255),
	number_of_rating NUMERIC,
	average_rating FLOAT
)

-- INSERTING INTO TABLE
INSERT INTO #NumberOfMoviesRatings
SELECT title, COUNT(rating), ROUND(AVG(rating),2) FROM portfolio_movielens.dbo.movies AS movies
FULL OUTER JOIN portfolio_movielens.dbo.ratings AS ratings
ON movies.movieId = ratings.movieId
GROUP BY title
ORDER BY COUNT(rating) DESC;

SELECT * FROM #NumberOfMoviesRatings
ORDER BY number_of_rating DESC;