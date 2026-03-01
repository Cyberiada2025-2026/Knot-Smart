klasa generatora dróg,

używanie: funkcja generate(Array) 
przyjmuje na wejściu: 
	- tablicę booleanów gdzie true to fragment terenu który nie pozwala stawiać drogi
zwraca:
	tablicę liczb od 0 do 35 gdzie każda zwraca poszczególny typ drogi( id są w enumach "road_id" i "highway_id" w kodzie )

		-1 - błąd autotile
		0 - brak drogi

		# zwykłe drogi
		1 - prosta droga pozioma
		2 - prosta droga pionowa
		3 - skrzyżowanie T w dół(zwykłe T, kierunek T oznacza skierowanie przyległego fragmentu drogi)
		4 - skrzyżowanie T w lewo
		5 - skrzyżowanie T w górę
		6 - skrzyżowanie T w prawo
		7 - skrzyżowanie +
		8 - zakręt z prawej do dołu
		9 - zakręt z lewej do dołu
		10 - zakręt z lewej do góry
		11 - zakręt z prawej do góry

		# główne drogi

		
		12 - górna część głównej drogi poziomej
		13 - górna część głównej drogi poziomej połączona z boczną drogą
		14 - prawa część głównej drogi pionowej
		15 - prawa część głównej drogi pionowej połączona z boczną drogą
		16 - dolna część głównej drogi poziomej
		17 - dolna część głównej drogi poziomej połączona z boczną drogą
		18 - lewa część głównej drogi pionowej
		19 - lewa część głównej drogi pionowej połączona z boczną drogą

		pozycje fragmentów poniżej są związane z pozycją w kwadracie 2x2 głównych dróg

		20 - lewy górny fragment skrzyżowania głównych dróg
		21 - prawy górny fragment skrzyżowania głównych dróg
		22 - prawy dolny fragment skrzyżowania głównych dróg
		23 - lewy dolny fragment skrzyżowania głównych dróg

		24 - zakręt głównej drogi połączony z główną drogą z dołu i prawej (główna droga ograniczona krawężnikami z 2 stron, ale mająca puste pozostałe 2 boki)
		to samo, ale z bocznymi drogami:
		25 - po lewej stronie
		26 - z góry 
		27 - z góry i z lewej strony

		28 - zakręt głównej drogi połączony z główną drogą z dołu i lewej strony
		to samo, ale z bocznymi drogami:
		29 - z góry
		30 - po prawej stronie
		31 - z góry i z prawej strony
		
		32 - zakręt głównej drogi połączony z główną drogą z góry i lewej strony
		to samo, ale z bocznymi drogami:
		33 - po prawej stronie
		34 - z dołu
		35 - z dołu i z prawej strony

		36 - zakręt głównej drogi połączony z główną drogą z góry i prawej strony
		to samo, ale z bocznymi drogami:
		37 - z dołu
		38 - po lewej stronie
		39 - z dołu i z lewej strony

		40 - skośny krawężnik co oddziela 2 główne drogi jak się połączą tylko rogiem, krawężnik z dołu po lewej do prawego górnego rogu
		41 - to samo, ale obrócone, krawężnik z dołu po prawej do lewego górnego rogu


! zakręty głównych dróg używają kilka ID obiektów z prostej głównej drogi - w przypadku modelu z oddzieleniem środka głównej drogi np. wysepką trzeba dodać oddzielne ID

config:
	klasa RoadGenerationParams, wszystko ustawiane w edytorze:

	conversion_limit_to_main_streets - liczba kroków generacji po której wszystkie obecnie wygenerowane drogi zostaną zamienione na główne drogi

	generation_areas(Array): 

	tablica obiektów LimitterArea(obszarów ograniczeń) gdzie można ustawić:

	- maksymalne i minimalne wymiary obszarów pod budynki:

		(WAŻNE: wymiary zostaną pomniejszone o 1 po konwersji mapy na mapę dróg, a niektóre nawet o 2, bo zostaną wygenerowane główne drogi)
		
		maksymalny rozmiar powinien być co najmniej dwukrotnie większy od minimalnego, żeby generacja była możliwa
		(jakby co poprawia automatycznie jeżeli się nie zgadzają)
	
	- promień obszaru na którym będą działać te ograniczenia:

		wartość od 0 do 1.0, która oznacza część promienia mapy na którym będą działać te ograniczenia

		wszystkie obszary aktualnie mają środek w środku mapy

		wartość domyślna dla całego terenu musi mieć promień 1.0, w przeciwnym wypadku zostaną użyte domyślne parametry(będą dodane do listy obszarów )
				

id na faktyczne obiekty 3D:
	podane nazwy bez rozszerzeń, podstawowe obiekty trzeba ustawić tak by obrotem pasowały do faktycznego opisu połaczeń z ID
	bo modele mogły się obrócic inaczej podczas eksportu
	obroty sa podane w stopniach, obrót zgodnie z ruchem wskazówek zegara, według osi Y w godocie
	
	-1 - empty

	0 - brak modelu, po prostu pusta przestrzeń dla budynków

	1 - road_straight
	2 - road_straight, obrót 90
	3 - road_T
	4 - road_T, obrót 90
	5 - road_T, obrót 180
	6 - road_T, obrót 270
	7 - road_crossroad
	8 - road_turn
	9 - road_turn, obrót 90
	10 - road_turn, obrót 180
	11 - road_turn, obrót 270

	12 - highway_straight
	13 - highway_straight_connected
	14 - highway_straight, obrót 90
	15 - highway_straight_connected, obrót 90

	dla następnych 4 ID najlepiej użyć odbicia lustrzanego poprzednich 4 ID by drogi wyglądały lepiej dla zaawansowanych modeli
	ewentualnie można użyć obrotów co są tu wpisane
	
	16 - highway_straight, obrót 180
	17 - highway_straight_connected, obrót 180
	18 - highway_straight, obrót 270
	19 - highway_straight_connected, obrót 270

	20 - highway_crossroad
	21 - highway_crossroad, obrót 90
	22 - highway_crossroad, obrót 180
	23 - highway_crossroad, obrót 270

	24 - highway_corner
	25 - highway_corner_connected(left)
	26 - highway_corner_connected_mirrored(up)
	27 - highway_corner_connected_both_sides

	(28-39 to 24-27 po kolei z obrotem 90, 180, 270)

	28 - highway_corner, obrót 90
	29 - highway_corner_connected(left), obrót 90
	30 - highway_corner_connected_mirrored(up), obrót 90
	31 - highway_corner_connected_both_sides, obrót 90

	32 - highway_corner, obrót 180
	33 - highway_corner_connected(left), obrót 180
	34 - highway_corner_connected_mirrored(up), obrót 180
	35 - highway_corner_connected_both_sides, obrót 180

	36 - highway_corner, obrót 270
	37 - highway_corner_connected(left), obrót 270
	38 - highway_corner_connected_mirrored(up), obrót 270
	39 - highway_corner_connected_both_sides, obrót 270

	40 - highway_diagonal
	41 - highway_diagonal, obrót 90
