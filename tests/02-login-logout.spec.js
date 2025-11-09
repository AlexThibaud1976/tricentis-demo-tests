const { test, expect } = require('@playwright/test');
const { createAccount, login, logout } = require('../utils/helpers');

test.describe('Tests de connexion et déconnexion', () => {
  let testUser;

  // Créer un compte avant d'exécuter les tests
  test.beforeAll(async ({ browser }) => {
    const context = await browser.newContext();
    const page = await context.newPage();
    testUser = await createAccount(page);
    
    // Se déconnecter après la création
    await logout(page);
    
    await context.close();
    console.log(`✅ Compte de test créé: ${testUser.email}`);
  });

  test('Test 3: Connexion utilisateur - Cas passant ✅', async ({ page }) => {
    // Naviguer vers la page d'accueil
    await page.goto('/');
    
    // Cliquer sur Log in
    await page.locator('a.ico-login').click();
    
    // Vérifier que nous sommes sur la page de connexion
    await expect(page).toHaveURL(/.*login/);
    
    // Remplir les identifiants
    await page.locator('input#Email').fill(testUser.email);
    await page.locator('input#Password').fill(testUser.password);
    
    // Cliquer sur Log in
    await page.locator('.button-1.login-button').click();
    
    // Attendre la redirection
    await page.waitForLoadState('networkidle');
    
    // Vérifier que nous sommes connectés
    await expect(page).toHaveURL('/');
    await expect(page.locator('a.ico-logout')).toBeVisible();
    await expect(page.locator('.account')).toContainText(testUser.email);
    
    // Vérifier que le lien "Log in" n'est plus visible
    await expect(page.locator('a.ico-login')).not.toBeVisible();
    
    console.log(`✅ Connexion réussie avec: ${testUser.email}`);
  });

  test('Test 4: Connexion utilisateur - Cas non passant (mot de passe incorrect) ❌', async ({ page }) => {
    await page.goto('/login');
    
    // Remplir avec un mauvais mot de passe
    await page.locator('input#Email').fill(testUser.email);
    await page.locator('input#Password').fill('MauvaisMotDePasse123');
    
    // Tenter de se connecter
    await page.locator('.button-1.login-button').click();
    
    // Vérifier le message d'erreur
    await expect(page.locator('.validation-summary-errors')).toBeVisible();
    await expect(page.locator('.validation-summary-errors')).toContainText('Login was unsuccessful');
    
    // Vérifier que nous sommes toujours sur la page de connexion
    await expect(page).toHaveURL(/.*login/);
    
    // Vérifier que nous ne sommes pas connectés
    await expect(page.locator('a.ico-login')).toBeVisible();
    
    console.log('✅ Le système a correctement rejeté le mot de passe incorrect');
  });

  test('Test 4 bis: Connexion - Cas non passant (email inexistant) ❌', async ({ page }) => {
    await page.goto('/login');
    
    await page.locator('input#Email').fill('emailinexistant@test.com');
    await page.locator('input#Password').fill('Password123');
    
    await page.locator('.button-1.login-button').click();
    
    await expect(page.locator('.validation-summary-errors')).toBeVisible();
    await expect(page.locator('.validation-summary-errors')).toContainText('Login was unsuccessful');
    
    console.log('✅ Le système a correctement rejeté l\'email inexistant');
  });

  test('Test 5: Déconnexion utilisateur - Cas passant ✅', async ({ page }) => {
    // D'abord se connecter
    await login(page, testUser.email, testUser.password);
    
    // Vérifier que nous sommes connectés
    await expect(page.locator('a.ico-logout')).toBeVisible();
    
    // Cliquer sur Log out
    await page.locator('a.ico-logout').click();
    
    // Attendre la redirection
    await page.waitForLoadState('networkidle');
    
    // Vérifier que nous sommes déconnectés
    await expect(page).toHaveURL('/');
    await expect(page.locator('a.ico-login')).toBeVisible();
    await expect(page.locator('a.ico-register')).toBeVisible();
    await expect(page.locator('a.ico-logout')).not.toBeVisible();
    
    console.log('✅ Déconnexion réussie');
  });
});
