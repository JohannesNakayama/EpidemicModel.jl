library(tidyverse)
library(magrittr)
library(ggpubr)
library(igraph)
library(viridis)
EXPERIMENT_NAME <- "main_policy_reach"
source(file.path("..", "helpers.R"))

# read and format config ---
arrow::read_feather(file.path("..", "..", "..", "experiments", EXPERIMENT_NAME, "configs.feather")) %>% 
  mutate(
    Config = as.factor(Config), 
    Nodes = as.numeric(Nodes), 
    N0 = as.numeric(N0), 
    K = as.numeric(K),
    AgentCount = as.numeric(AgentCount), 
    TransmissionProb = as.numeric(TransmissionProb),
    TestProb = as.numeric(TestProb), 
    QuarantineDuration = as.numeric(QuarantineDuration),
    BehaviorReductionFactor = as.numeric(BehaviorReductionFactor), 
    BehaviorActivated = as.logical(BehaviorActivated),
    TickAuthorityRecommendation = as.numeric(TickAuthorityRecommendation),
    TickAuthorityPolicy = as.numeric(TickAuthorityPolicy),
    PublicSpaces = as.numeric(PublicSpaces),
    InitialInfectives = as.numeric(InitialInfectives),
    Iterations = as.numeric(Iterations)
  ) -> config

# read and format summary statistics ---
arrow::read_feather(file.path("..", "..", "..", "experiments", EXPERIMENT_NAME, "summary_statistics.feather")) %>% 
  mutate(
    Config = as.factor(Config),
    Replicate = as.numeric(Replicate),
    BehaviorActivated = as.logical(BehaviorActivated),
    AgentCount = as.numeric(AgentCount),
    Nodes = as.numeric(Nodes),
    PublicSpaces = as.numeric(PublicSpaces),
    BehaviorReductionFactor = as.numeric(BehaviorReductionFactor),
    TickAuthorityRecommendation = as.numeric(TickAuthorityRecommendation),
    TickAuthorityPolicy = as.numeric(TickAuthorityPolicy),
    TransmissionProb = as.numeric(TransmissionProb),
    QuarantineDuration = as.numeric(QuarantineDuration),
    PeakInfectiveCount = as.numeric(PeakInfectiveCount),
    TickOfPeakInfectiveCount = as.numeric(TickOfPeakInfectiveCount),
    DurationOfEpidemic = as.numeric(DurationOfEpidemic),
    FractionStillSusceptible = as.numeric(FractionStillSusceptible),
    PeakInfectiveFraction = PeakInfectiveCount / AgentCount
  ) -> summary_statistics

# aggregate summary statistics ---
summary_statistics %>% 
  group_by(Config, PublicSpaces) %>%
  summarize(
    PeakInfectiveCountMean = mean(PeakInfectiveCount),
    PeakInfectiveCountSE = standard_error(PeakInfectiveCount),
    PeakInfectiveFractionMean = mean(PeakInfectiveFraction),
    PeakInfectiveFractionSE = standard_error(PeakInfectiveFraction),
    TickOfPeakInfectiveCountMean = mean(TickOfPeakInfectiveCount),
    TickOfPeakInfectiveCountSE = standard_error(TickOfPeakInfectiveCount),
    DurationOfEpidemicMean = mean(DurationOfEpidemic),
    DurationOfEpidemicSE = standard_error(DurationOfEpidemic),
    FractionStillSusceptibleMean = mean(FractionStillSusceptible),
    FractionStillSusceptibleSE = standard_error(FractionStillSusceptible)
  ) %>% 
  ungroup() -> summary_statistics_aggregated

# read and format mdata --- 
dir <- file.path("..", "..", "..", "experiments", EXPERIMENT_NAME)
archive_filename <- file.path(dir, "mdata.7z")
unpack_7z_command <- paste0("7z x ", archive_filename)
system(unpack_7z_command)
mdata <- data.frame()
for (config_key in 1:dim(config)[1]) {
  config_nr <- stringr::str_pad(config_key, 2, "left", "0")
  filename <- paste0("config_", config_nr, "_mdata.feather")
  df <- arrow::read_feather(filename)
  df$Config <- paste0("config_", config_nr)
  mdata %<>% bind_rows(df)
}
system("rm *.feather")
mdata %<>%
  tibble() %>% 
  mutate(
    Config = as.factor(Config),
    Replicate = as.numeric(Replicate),
    Step = as.numeric(Step),
    Day = floor(Step / 10),
    SCount = as.numeric(SCount),
    ECount = as.numeric(ECount),
    IuCount = as.numeric(IuCount),
    IdCount = as.numeric(IdCount),
    ICount = as.numeric(ICount),
    RCount = as.numeric(RCount),
    BCount = as.numeric(BCount),
    IdCumulative = as.numeric(IdCumulative),
    ICumulative = as.numeric(ICumulative),
    NewCasesReal = as.numeric(NewCasesReal),
    NewCasesDetected = as.numeric(NewCasesDetected)
  )

# pivot mdata long ---
mdata %>% 
  pivot_longer(
    cols = c(
      SCount, ECount, IuCount, IdCount, 
      ICount, RCount, BCount, IdCumulative, 
      ICumulative, NewCasesReal, NewCasesDetected
    ),
    names_to = "Concept",
    values_to = "Value"
  ) %>% 
  inner_join(config %>% select(Config, AgentCount), by = "Config") %>% 
  mutate(Fraction = Value / AgentCount) %>% 
  select(-AgentCount) %>% 
  mutate(Concept = as.factor(Concept)) -> mdata_long

# summarize mdata ---
mdata %>% 
  group_by(Step, Day, Config) %>% 
  summarize(
    SCountMean = mean(SCount), 
    SCountSE = standard_error(SCount),
    ECountMean = mean(ECount), 
    ECountSE = standard_error(ECount),
    IuCountMean = mean(IuCount), 
    IuCountSE = standard_error(IuCount),
    IdCountMean = mean(IdCount), 
    IdCountSE = standard_error(IdCount),
    ICountMean = mean(ICount), 
    ICountSE = standard_error(ICount),
    RCountMean = mean(RCount), 
    RCountSE = standard_error(RCount),
    BCountMean = mean(BCount), 
    BCountSE = standard_error(BCount),
    IdCumulativeMean = mean(IdCumulative), 
    IdCumulativeSE = standard_error(IdCumulative),
    ICumulativeMean = mean(ICumulative), 
    ICumulativeSE = standard_error(ICumulative),
    NewCasesRealMean = mean(NewCasesReal), 
    NewCasesRealSE = standard_error(NewCasesReal),
    NewCasesDetectedMean = mean(NewCasesDetected), 
    NewCasesDetectedSE = standard_error(NewCasesDetected)
  ) %>% 
  ungroup() %>% 
  mutate(
    SCountLower = SCountMean - SCountSE, 
    SCountUpper = SCountMean + SCountSE,
    ECountLower = ECountMean - ECountSE, 
    ECountUpper = ECountMean + ECountSE,
    IuCountLower = IuCountMean - IuCountSE, 
    IuCountUpper = IuCountMean + IuCountSE,
    IdCountLower = IdCountMean - IdCountSE, 
    IdCountUpper = IdCountMean + IdCountSE,
    ICountLower = ICountMean - ICountSE, 
    ICountUpper = ICountMean + ICountSE,
    RCountLower = RCountMean - RCountSE, 
    RCountUpper = RCountMean + RCountSE,
    BCountLower = BCountMean - BCountSE, 
    BCountUpper = BCountMean + BCountSE,
    IdCumulativeLower = IdCumulativeMean - IdCumulativeSE,
    IdCumulativeUpper = IdCumulativeMean + IdCumulativeSE,
    ICumulativeLower = ICumulativeMean - ICumulativeSE,
    ICumulativeUpper = ICumulativeMean + ICumulativeSE,
    NewCasesRealLower = NewCasesRealMean - NewCasesRealSE,
    NewCasesRealUpper = NewCasesRealMean + NewCasesRealSE,
    NewCasesDetectedLower = NewCasesDetectedMean - NewCasesDetectedSE,
    NewCasesDetectedUpper = NewCasesDetectedMean + NewCasesDetectedSE
  ) %>% 
  select(
    -c(
      SCountMean, SCountSE, ECountMean, ECountSE, 
      IuCountMean, IuCountSE, IdCountMean, IdCountSE, 
      ICountMean, ICountSE, RCountMean, RCountSE, 
      BCountMean, BCountSE, IdCumulativeMean, IdCumulativeSE, 
      ICumulativeMean, ICumulativeSE, NewCasesRealMean, NewCasesRealSE, 
      NewCasesDetectedMean, NewCasesDetectedSE
    )
  ) -> mdata_summarized

# pivot summarized mdata long ---
mdata_summarized %>% 
  pivot_longer(
    cols = c(
      SCountLower, SCountUpper, ECountLower, ECountUpper, 
      IuCountLower, IuCountUpper, IdCountLower, IdCountUpper,
      ICountLower, ICountUpper, RCountLower, RCountUpper, 
      BCountLower, BCountUpper, IdCumulativeLower, IdCumulativeUpper, 
      ICumulativeLower, ICumulativeUpper, NewCasesRealLower, NewCasesRealUpper, 
      NewCasesDetectedLower, NewCasesDetectedUpper
    ),
    names_to = "Concept",
    values_to = "Value"
  ) %>% 
  inner_join(config %>% select(Config, AgentCount), by = "Config") %>% 
  mutate(Class = sub("Lower|Upper", "", Concept)) %>% 
  mutate(Fraction = Value / AgentCount) %>% 
  select(-AgentCount) %>% 
  mutate(Class = as.factor(Class)) -> mdata_summarized_long

# read and format summary agent states ---
arrow::read_feather(file.path("..", "..", "..", "experiments", EXPERIMENT_NAME, "summary_agent_states.feather")) %>% 
  mutate(
    Config = as.factor(Config),
    Replicate = as.numeric(Replicate),
    Step = as.numeric(Step),
    Day = floor(Step / 10),
    FearMean = as.numeric(FearMean),
    FearSE = as.numeric(FearSE),
    FearSD = as.numeric(FearSD),
    FearMin = as.numeric(FearMin),
    FearMax = as.numeric(FearMax),
    SocialNormMean = as.numeric(SocialNormMean),
    SocialNormSE = as.numeric(SocialNormSE),
    SocialNormSD = as.numeric(SocialNormSD),
    SocialNormMin = as.numeric(SocialNormMin),
    SocialNormMax = as.numeric(SocialNormMax),
    BehaviorCount = as.numeric(BehaviorCount)
  ) -> summary_agent_states

# save and reset ---
save(
  list = c(
    "config", "mdata", "mdata_long", "mdata_summarized", 
    "mdata_summarized_long", "summary_agent_states",
    "summary_statistics", "summary_statistics_aggregated"
  ),
  file = file.path("data.RData")
)
rm(archive_filename, config_key, config_nr, df, dir, filename, unpack_7z_command)