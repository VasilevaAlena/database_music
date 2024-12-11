/* Название и продолжительность самого длительного трека.*/
SELECT song, duration FROM track
WHERE duration = (SELECT MAX(duration) FROM track);

/* Название треков, продолжительность которых не менее 3,5 минут.*/
SELECT song FROM track
WHERE duration >= 210;

/* Названия сборников, вышедших в период с 2018 по 2020 год включительно.*/
SELECT title FROM collections
WHERE release BETWEEN 2018 AND 2020;

/* Исполнители, чьё имя состоит из одного слова.*/
SELECT executor FROM singer
WHERE executor NOT LIKE '% %';

/* Название треков, которые содержат слово «мой» или «my».*/
SELECT song FROM track
WHERE song ILIKE 'my %' 
	OR song ILIKE '% my'
	OR song ILIKE '% my %'
	OR song ILIKE 'my';

/* Количество исполнителей в каждом жанре.*/
SELECT g.genre, COUNT(singer_id) singer_count FROM singergenre s
JOIN genre g ON s.genre_id = g.id
GROUP BY g.genre
ORDER BY singer_count DESC;

/* Количество треков, вошедших в альбомы 2019–2020 годов.*/
SELECT COUNT(albom_id) song_count FROM track t
JOIN albom a ON t.albom_id = a.id
WHERE release BETWEEN 2019 AND 2020;

/* Средняя продолжительность треков по каждому альбому.*/
SELECT a.title, AVG(duration) FROM track t
JOIN albom a ON t.albom_id = a.id
GROUP BY a.title
ORDER BY AVG(duration) DESC;

/* Все исполнители, которые не выпустили альбомы в 2020 году. */
SELECT s.executor FROM singer s
WHERE s.id NOT IN (
	SELECT a2.singer_id FROM albomsinger a2
	JOIN albom a ON a.id = a2.albom_id
	WHERE a.release = 2020)
    
/* Названия сборников, в которых присутствует конкретный исполнитель (выберите его сами).*/
SELECT c.title FROM collections c
RIGHT JOIN collectiontrack ct ON c.id = ct.collection_id 
JOIN track t ON t.id = ct.track_id 
JOIN albom a ON a.id = t.albom_id
JOIN albomsinger a2 ON a2.albom_id = a.id
JOIN singer s ON s.id = a2.singer_id
WHERE s.executor = 'Ariana'
GROUP BY c.title;

/* Названия альбомов, в которых присутствуют исполнители более чем одного жанра.*/
SELECT a.title FROM albom a 
RIGHT JOIN albomsinger a2 ON a2.albom_id = a.id
JOIN singer s ON s.id = a2.singer_id
JOIN (SELECT singer_id FROM singergenre 
	GROUP BY singer_id) sg ON sg.singer_id = s.id
GROUP BY a.title
HAVING COUNT(a.title) > 1;

/* Наименования треков, которые не входят в сборники.*/
SELECT t.song FROM track t
LEFT JOIN collectiontrack c ON c.track_id = t.id
WHERE c.collection_id IS NULL;

/* Исполнитель или исполнители, написавшие самый короткий по продолжительности 
трек, — теоретически таких треков может быть несколько.*/
SELECT s.executor FROM singer s
JOIN albomsinger a2 ON s.id = a2.singer_id 
JOIN albom a ON a.id = a2.albom_id
FULL JOIN track t ON t.albom_id = a.id
WHERE t.duration = (SELECT MIN(duration) min_time FROM track)
GROUP BY s.executor;

/* Названия альбомов, содержащих наименьшее количество треков.*/
SELECT a.title, COUNT(t.song) count_song FROM albom a
JOIN track t ON t.albom_id = a.id
GROUP BY a.title
HAVING COUNT(t.song) = 
    (SELECT COUNT(t.song) FROM albom a
     JOIN track t ON t.albom_id = a.id
     GROUP BY a.title
     ORDER BY COUNT(t.id)
     LIMIT 1);