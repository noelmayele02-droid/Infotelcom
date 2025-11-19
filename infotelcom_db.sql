-- ============================================
-- BASE DE DONNÉES INFOTELCOM
-- Système de Gestion des Formations IT
-- ============================================

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS infotelcom_db;
USE infotelcom_db;

-- ============================================
-- 1. TABLE DES UTILISATEURS
-- ============================================
CREATE TABLE utilisateurs (
    id_utilisateur INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telephone VARCHAR(20),
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    role ENUM('etudiant', 'formateur', 'admin', 'entreprise') DEFAULT 'etudiant',
    statut ENUM('actif', 'inactif', 'suspendu') DEFAULT 'actif',
    date_derniere_connexion DATETIME,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- ============================================
-- 2. TABLE DES DOMAINES DE SPÉCIALISATION
-- ============================================
CREATE TABLE domaines (
    id_domaine INT PRIMARY KEY AUTO_INCREMENT,
    nom_domaine VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    couleur_badge VARCHAR(7),
    ordre_affichage INT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. TABLE DES FORMATIONS
-- ============================================
CREATE TABLE formations (
    id_formation INT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    id_domaine INT NOT NULL,
    duree_mois INT NOT NULL,
    niveau ENUM('Débutant', 'Intermédiaire', 'Avancé') NOT NULL,
    prix DECIMAL(10, 2) NOT NULL,
    statut_formation ENUM('Actif', 'Inactif', 'À venir', 'Complet') DEFAULT 'Actif',
    nombre_places_max INT DEFAULT 30,
    nombre_inscrits INT DEFAULT 0,
    date_debut DATETIME,
    date_fin DATETIME,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_domaine) REFERENCES domaines(id_domaine),
    INDEX idx_domaine (id_domaine),
    INDEX idx_niveau (niveau),
    INDEX idx_statut (statut_formation)
);

-- ============================================
-- 4. TABLE DES TAGS/COMPÉTENCES
-- ============================================
CREATE TABLE tags_competences (
    id_tag INT PRIMARY KEY AUTO_INCREMENT,
    nom_tag VARCHAR(100) NOT NULL UNIQUE,
    categorie VARCHAR(50)
);

-- ============================================
-- 5. TABLE D'ASSOCIATION FORMATION-TAGS
-- ============================================
CREATE TABLE formation_tags (
    id_formation INT NOT NULL,
    id_tag INT NOT NULL,
    PRIMARY KEY (id_formation, id_tag),
    FOREIGN KEY (id_formation) REFERENCES formations(id_formation) ON DELETE CASCADE,
    FOREIGN KEY (id_tag) REFERENCES tags_competences(id_tag) ON DELETE CASCADE
);

-- ============================================
-- 6. TABLE DES INSCRIPTIONS AUX FORMATIONS
-- ============================================
CREATE TABLE inscriptions (
    id_inscription INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT NOT NULL,
    id_formation INT NOT NULL,
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut_inscription ENUM('en_attente', 'confirmee', 'completee', 'abandonnee') DEFAULT 'en_attente',
    progression_percentage INT DEFAULT 0,
    certificat_obtenu BOOLEAN DEFAULT FALSE,
    date_completion DATETIME,
    note_finale DECIMAL(5, 2),
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur),
    FOREIGN KEY (id_formation) REFERENCES formations(id_formation),
    INDEX idx_utilisateur (id_utilisateur),
    INDEX idx_formation (id_formation),
    INDEX idx_statut (statut_inscription),
    UNIQUE KEY unique_inscription (id_utilisateur, id_formation)
);

-- ============================================
-- 7. TABLE DES FORMATEURS
-- ============================================
CREATE TABLE formateurs (
    id_formateur INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT NOT NULL UNIQUE,
    specialisation VARCHAR(200),
    experience_annees INT,
    bio TEXT,
    photo_url VARCHAR(255),
    date_embauche DATE,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
);

-- ============================================
-- 8. TABLE D'ASSOCIATION FORMATION-FORMATEURS
-- ============================================
CREATE TABLE formation_formateurs (
    id_formation INT NOT NULL,
    id_formateur INT NOT NULL,
    role_formateur ENUM('principal', 'assistant', 'intervenant') DEFAULT 'assistant',
    PRIMARY KEY (id_formation, id_formateur),
    FOREIGN KEY (id_formation) REFERENCES formations(id_formation) ON DELETE CASCADE,
    FOREIGN KEY (id_formateur) REFERENCES formateurs(id_formateur) ON DELETE CASCADE
);

-- ============================================
-- 9. TABLE DES MODULES/LEÇONS
-- ============================================
CREATE TABLE modules (
    id_module INT PRIMARY KEY AUTO_INCREMENT,
    id_formation INT NOT NULL,
    titre_module VARCHAR(200) NOT NULL,
    description TEXT,
    ordre_module INT,
    duree_heures INT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_formation) REFERENCES formations(id_formation) ON DELETE CASCADE,
    INDEX idx_formation (id_formation)
);

-- ============================================
-- 10. TABLE DES CONTENUS/LEÇONS
-- ============================================
CREATE TABLE contenus (
    id_contenu INT PRIMARY KEY AUTO_INCREMENT,
    id_module INT NOT NULL,
    titre_contenu VARCHAR(200) NOT NULL,
    description TEXT,
    type_contenu ENUM('video', 'texte', 'exercice', 'quiz', 'projet') DEFAULT 'texte',
    url_contenu VARCHAR(500),
    ordre_contenu INT,
    duree_minutes INT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_module) REFERENCES modules(id_module) ON DELETE CASCADE,
    INDEX idx_module (id_module)
);

-- ============================================
-- 11. TABLE DES TEMOIGNAGES
-- ============================================
CREATE TABLE temoignages (
    id_temoignage INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT,
    titre_poste VARCHAR(200) NOT NULL,
    contenu_temoignage TEXT NOT NULL,
    note_satisfaction INT CHECK (note_satisfaction BETWEEN 1 AND 5),
    date_temoignage DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut_publication ENUM('publie', 'non_publie', 'en_attente') DEFAULT 'en_attente',
    id_formation INT,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur),
    FOREIGN KEY (id_formation) REFERENCES formations(id_formation),
    INDEX idx_publication (statut_publication)
);

-- ============================================
-- 12. TABLE DES DEMANDES DE CONTACT
-- ============================================
CREATE TABLE demandes_contact (
    id_demande INT PRIMARY KEY AUTO_INCREMENT,
    prenom VARCHAR(100) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    telephone VARCHAR(20),
    domaine_interet VARCHAR(200),
    message TEXT NOT NULL,
    date_demande DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut_traitement ENUM('nouvelle', 'en_cours', 'repondue', 'fermee') DEFAULT 'nouvelle',
    date_traitement DATETIME,
    INDEX idx_email (email),
    INDEX idx_statut (statut_traitement)
);

-- ============================================
-- 13. TABLE DES CERTIFICATS
-- ============================================
CREATE TABLE certificats (
    id_certificat INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT NOT NULL,
    id_formation INT NOT NULL,
    numero_certificat VARCHAR(100) UNIQUE NOT NULL,
    date_obtention DATE NOT NULL,
    niveau_certification VARCHAR(100),
    url_certificat VARCHAR(255),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur),
    FOREIGN KEY (id_formation) REFERENCES formations(id_formation),
    INDEX idx_utilisateur (id_utilisateur),
    INDEX idx_numero (numero_certificat)
);

-- ============================================
-- 14. TABLE DES ENTREPRISES PARTENAIRES
-- ============================================
CREATE TABLE entreprises_partenaires (
    id_entreprise INT PRIMARY KEY AUTO_INCREMENT,
    nom_entreprise VARCHAR(200) NOT NULL,
    secteur_activite VARCHAR(100),
    email_contact VARCHAR(150),
    telephone_contact VARCHAR(20),
    adresse VARCHAR(255),
    site_web VARCHAR(255),
    logo_url VARCHAR(255),
    date_partenariat DATE,
    statut_partenariat ENUM('actif', 'inactif', 'suspendu') DEFAULT 'actif'
);

-- ============================================
-- 15. TABLE DES OFFRES D'EMPLOI
-- ============================================
CREATE TABLE offres_emploi (
    id_offre INT PRIMARY KEY AUTO_INCREMENT,
    id_entreprise INT NOT NULL,
    titre_poste VARCHAR(200) NOT NULL,
    description_offre TEXT NOT NULL,
    competences_requises TEXT,
    salaire_min DECIMAL(10, 2),
    salaire_max DECIMAL(10, 2),
    type_contrat ENUM('CDI', 'CDD', 'Stage', 'Freelance') DEFAULT 'CDI',
    localisation VARCHAR(255),
    date_publication DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_limite DATETIME,
    statut_offre ENUM('ouvert', 'ferme', 'pourvue') DEFAULT 'ouvert',
    FOREIGN KEY (id_entreprise) REFERENCES entreprises_partenaires(id_entreprise),
    INDEX idx_entreprise (id_entreprise),
    INDEX idx_statut (statut_offre)
);

-- ============================================
-- 16. TABLE DES CANDIDATURES
-- ============================================
CREATE TABLE candidatures (
    id_candidature INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT NOT NULL,
    id_offre INT NOT NULL,
    date_candidature DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut_candidature ENUM('nouvelle', 'vue', 'en_cours', 'acceptee', 'rejetee') DEFAULT 'nouvelle',
    lettre_motivation TEXT,
    cv_url VARCHAR(255),
    date_traitement DATETIME,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur),
    FOREIGN KEY (id_offre) REFERENCES offres_emploi(id_offre),
    INDEX idx_utilisateur (id_utilisateur),
    INDEX idx_offre (id_offre),
    UNIQUE KEY unique_candidature (id_utilisateur, id_offre)
);

-- ============================================
-- 17. TABLE DES PAIEMENTS
-- ============================================
CREATE TABLE paiements (
    id_paiement INT PRIMARY KEY AUTO_INCREMENT,
    id_inscription INT NOT NULL,
    montant DECIMAL(10, 2) NOT NULL,
    methode_paiement ENUM('carte', 'virement', 'especes', 'cheque') DEFAULT 'carte',
    date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut_paiement ENUM('en_attente', 'confirme', 'refuse', 'remboursé') DEFAULT 'en_attente',
    reference_transaction VARCHAR(100),
    FOREIGN KEY (id_inscription) REFERENCES inscriptions(id_inscription),
    INDEX idx_inscription (id_inscription),
    INDEX idx_statut (statut_paiement)
);

-- ============================================
-- 18. TABLE DES STATISTIQUES/ANALYTICS
-- ============================================
CREATE TABLE analytics (
    id_analytics INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT,
    id_formation INT,
    action VARCHAR(50),
    date_action DATETIME DEFAULT CURRENT_TIMESTAMP,
    details JSON,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur),
    FOREIGN KEY (id_formation) REFERENCES formations(id_formation),
    INDEX idx_date (date_action),
    INDEX idx_utilisateur (id_utilisateur)
);

-- ============================================
-- INSERTION DES DONNÉES INITIALES
-- ============================================

-- Domaines
INSERT INTO domaines (nom_domaine, description, couleur_badge, ordre_affichage) VALUES
('Développement Logiciel', 'Créez des applications et systèmes modernes', '#3B82F6', 1),
('Sécurité Numérique', 'Protégez les systèmes contre les menaces', '#EF4444', 2),
('Création & Stratégie', 'Conçevez des expériences numériques', '#8B5CF6', 3),
('Data & IA', 'Analysez et exploitez les données avec l\'IA', '#F59E0B', 4);

-- Tags/Compétences
INSERT INTO tags_competences (nom_tag, categorie) VALUES
('React', 'Frontend'),
('Node.js', 'Backend'),
('MongoDB', 'Base de Données'),
('Architecture Cloud', 'Cloud'),
('Tests d\'intrusion', 'Sécurité'),
('Linux', 'Systèmes'),
('Cryptographie', 'Sécurité'),
('Sécurité Réseau', 'Sécurité'),
('SEO', 'Marketing'),
('Google Ads', 'Marketing'),
('Design System', 'Design'),
('Figma', 'Design'),
('Python', 'Programmation'),
('Machine Learning', 'IA'),
('Analyse Statistique', 'Data'),
('Docker', 'DevOps'),
('Kubernetes', 'DevOps'),
('AWS/Azure', 'Cloud');

-- ============================================
-- CRÉER LES INDEX SUPPLÉMENTAIRES
-- ============================================
CREATE INDEX idx_formations_domaine_statut ON formations(id_domaine, statut_formation);
CREATE INDEX idx_inscriptions_statut ON inscriptions(id_utilisateur, statut_inscription);
CREATE INDEX idx_paiements_statut ON paiements(id_inscription, statut_paiement);