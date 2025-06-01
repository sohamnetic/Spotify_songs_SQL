create table spotify_tracks(
artist varchar(255),
song varchar(255),
duration_ms int,
explicit1 varchar(255),
year1 int,
popularity int,
danceability float,
energy float,
key1 int,
loudness float,
mode int,
speechiness float,
acousticness float,
instrumentalness float,
liveness float,
valence float,
tempo float,
genre varchar(255))

bulk insert dbo.spotify_tracks from 'C:\Users\lenovo\Downloads\songs_normalize.csv' with (format='csv',firstrow=2)

select * from spotify_tracks

--List all artists ordered by the number of songs they have in the dataset
select artist,count(*) as song_count from spotify_tracks group by artist order by song_count desc 

--What is the average danceability and energy score by genre?
select genre,round(avg(danceability),4) as avg_danceability,round(avg(energy),4) as avg_energy from spotify_tracks group by genre order by avg_danceability desc 

--What are the top 10 most popular songs of all time?
select top(10) song from spotify_tracks order by popularity desc

--Which year had the highest number of song releases?
select top(1)year1,count(song) as count_song from spotify_tracks group by year1 order by count_song desc

--Find the top 5 artists with the highest average loudness
select top(5)artist,avg(loudness) as avg_loudness from spotify_tracks group by artist order by avg_loudness desc

--List all genres with average popularity above 70
select genre,avg(popularity) as avg_popularity from spotify_tracks group by genre having avg(popularity)>70 order by avg_popularity desc

--For each year, rank the top 3 songs by popularity
select * from(select year1,song,artist,popularity,ROW_NUMBER() over(partition by year1 order by popularity desc) as rank1 from spotify_tracks) ranked_songs where rank1<=3

--How has the average energy of songs changed over years
select year1,round(avg(energy),3) as avg_energy from spotify_tracks group by year1 order by year1

--Is there a trend in valence (positiveness) over time
select year1,round(avg(valence),3) as avg_valence from spotify_tracks group by year1 order by year1

--Which genre has the highest average instrumentalness?
select top(1)genre,avg(instrumentalness) as avg_instrumentalness from spotify_tracks group by genre order by avg_instrumentalness desc

--Which artist’s songs are most likely to be acoustic
select top(5)artist,avg(acousticness) as avg_acousticness from spotify_tracks group by artist order by avg_acousticness desc

--Identify songs with low popularity (popularity < 60) but high energy and danceability (both > 0.8)
select artist, song from spotify_tracks where popularity < 60 and energy > 0.8 and danceability > 0.8

--relationship between song duration and popularity? Group songs by duration ranges (e.g., short, medium, long) and compare average popularity
select
    iif(duration_ms<180000,'short',
        iif(duration_ms between 180000 and 240000,'medium','long')
    )as duration_category,
    avg(popularity) as avg_popularity
from spotify_tracks
group by
    iif(duration_ms<180000,'short',
        iif(duration_ms between 180000 and 240000,'medium','long'))order by avg_popularity desc

--What is the difference in average loudness and energy between explicit and non-explicit songs?
select explicit1,avg(loudness) as avg_loudness,avg(energy) as avg_energy from spotify_tracks group by explicit1

--For each year, what is the song with the highest energy level?
select year1,song,artist,energy from spotify_tracks s
where energy = (
        select max(energy) from spotify_tracks where year1 = s.year1)
order by year1
