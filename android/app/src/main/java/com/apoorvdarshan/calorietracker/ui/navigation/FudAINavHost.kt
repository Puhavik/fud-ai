package com.apoorvdarshan.calorietracker.ui.navigation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.apoorvdarshan.calorietracker.AppContainer
import com.apoorvdarshan.calorietracker.services.update.AndroidUpdateChecker
import com.apoorvdarshan.calorietracker.services.update.AndroidUpdateState
import com.apoorvdarshan.calorietracker.ui.about.AboutScreen
import com.apoorvdarshan.calorietracker.ui.coach.CoachScreen
import com.apoorvdarshan.calorietracker.ui.home.HomeScreen
import com.apoorvdarshan.calorietracker.ui.onboarding.OnboardingScreen
import com.apoorvdarshan.calorietracker.ui.progress.ProgressScreen
import com.apoorvdarshan.calorietracker.ui.settings.OptionalNutrientGoalsScreen
import com.apoorvdarshan.calorietracker.ui.settings.SettingsScreen

@Composable
fun FudAINavHost(
    container: AppContainer,
    startOnboarding: Boolean
) {
    val nav = rememberNavController()
    val backStack by nav.currentBackStackEntryAsState()
    val currentRoute = backStack?.destination?.route
    // Hide the bar while a food analysis is in flight so the AnalyzingOverlay
    // is the only thing on screen — matches iOS, where the analyzing sheet
    // covers the tab bar.
    val analyzing by container.analyzingFood.collectAsState()
    val showTabs = currentRoute in FudAIRoutes.bottomTabs && !analyzing
    val context = LocalContext.current
    val currentVersion = remember(context) { AndroidUpdateChecker.currentVersion(context) }
    var updateAvailable by remember { mutableStateOf(false) }

    LaunchedEffect(currentVersion) {
        updateAvailable = AndroidUpdateChecker.check(currentVersion) is AndroidUpdateState.Available
    }

    Scaffold(
        bottomBar = {
            if (showTabs) {
                FudAIBottomNavBar(
                    currentRoute = currentRoute,
                    showAboutBadge = updateAvailable,
                    onTap = { target ->
                        if (target == currentRoute) return@FudAIBottomNavBar
                        // Tapping HOME (the start destination) needs popBackStack
                        // — `navigate(HOME) { popUpTo(HOME); launchSingleTop = true }`
                        // is a no-op because NavController sees HOME at the top of
                        // the stack and skips re-emitting currentBackStackEntry, so
                        // the bar stays selected on the previous tab.
                        if (target == FudAIRoutes.HOME) {
                            nav.popBackStack(FudAIRoutes.HOME, inclusive = false)
                        } else {
                            nav.navigate(target) {
                                popUpTo(FudAIRoutes.HOME) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    }
                )
            }
        }
    ) { padding ->
        Box(Modifier.fillMaxSize().padding(padding)) {
            NavHost(
                navController = nav,
                startDestination = if (startOnboarding) FudAIRoutes.ONBOARDING else FudAIRoutes.HOME
            ) {
                composable(FudAIRoutes.ONBOARDING) {
                    OnboardingScreen(container = container, onComplete = {
                        nav.navigate(FudAIRoutes.HOME) {
                            popUpTo(FudAIRoutes.ONBOARDING) { inclusive = true }
                            launchSingleTop = true
                        }
                    })
                }
                composable(FudAIRoutes.HOME) { HomeScreen(container = container) }
                composable(FudAIRoutes.PROGRESS) { ProgressScreen(container = container) }
                composable(FudAIRoutes.COACH) { CoachScreen(container = container) }
                composable(FudAIRoutes.SETTINGS) { SettingsScreen(container = container, nav = nav) }
                composable(FudAIRoutes.OPTIONAL_NUTRIENT_GOALS) {
                    OptionalNutrientGoalsScreen(container = container, onBack = { nav.popBackStack() })
                }
                composable(FudAIRoutes.ABOUT) { AboutScreen(container = container) }
            }
        }
    }
}

internal fun NavHostController.current(): String? = currentBackStackEntry?.destination?.route
